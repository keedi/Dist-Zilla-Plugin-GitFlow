package Dist::Zilla::Plugin::GitFlow::Init;
# ABSTRACT: initialize git repository and git-flow setting on dzil new

use Moose;

our %transform = (
    lc => sub { lc shift },
    uc => sub { uc shift },
    '' => sub { shift },
);

use Git::Wrapper;
use String::Formatter method_stringf => {
    -as   => '_format_string',
    codes => {
        n => sub { "\n" },
        N => sub { $transform{ $_[1] || '' }->( $_[0]->zilla->name ) },
    },
};

with 'Dist::Zilla::Role::AfterMint';

has commit_message => (
    is      => 'ro',
    isa     => 'Str',
    default => 'Start develop branch for first release',
);

has remotes => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
);

has config_entries => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
);

sub mvp_multivalue_args { qw(config_entries remotes) }
sub mvp_aliases { return { config => 'config_entries', remote => 'remotes' } }

has branch_master => (
    is      => 'ro',
    isa     => 'Str',
    default => 'master',
);

has branch_develop => (
    is      => 'ro',
    isa     => 'Str',
    default => 'develop',
);

has prefix_feature => (
    is      => 'ro',
    isa     => 'Str',
    default => 'feature/',
);

has prefix_release => (
    is      => 'ro',
    isa     => 'Str',
    default => 'release/',
);

has prefix_hotfix => (
    is      => 'ro',
    isa     => 'Str',
    default => 'hotfix/',
);

has prefix_support => (
    is      => 'ro',
    isa     => 'Str',
    default => 'support/',
);

has prefix_versiontag => (
    is      => 'ro',
    isa     => 'Str',
    default => 'v',
);

sub after_mint {
    my $self = shift;
    my ($opts) = @_;

    my $git = Git::Wrapper->new($opts->{mint_root});
    $self->log("Initializing a new git repository in " . $opts->{mint_root});
    $git->init;

    for my $config (qw/
        branch_master
        branch_develop
        prefix_feature
        prefix_release
        prefix_hotfix
        prefix_support
        prefix_versiontag
    /)
    {
        ( my $key = "gitflow.$config" ) =~ s/_/./;
        my $val;
        $val = $self->$config if $self->can($config);

        if ($val) {
            $self->log_debug("Configuring $key $val");
            $git->config($key, $val);
        }
    }

    $self->log("Initializing git-flow in $opts->{mint_root}");
    $git->flow( 'init', '-fd' );

    foreach my $configSpec (@{ $self->config_entries }) {
        my ($option, $value) = split ' ', _format_string($configSpec, $self), 2;
        $self->log_debug("Configuring $option $value");
        $git->config($option, $value);
    }

    $git->add($opts->{mint_root});
    $git->commit({message => _format_string($self->commit_message, $self)});
    foreach my $remoteSpec (@{ $self->remotes }) {
        my ($remote, $url) = split ' ', _format_string($remoteSpec, $self), 2;
        $self->log_debug("Adding remote $remote as $url");
        $git->remote(add => $remote, $url);
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
__END__

=for Pod::Coverage
    after_mint mvp_aliases mvp_multivalue_args

=head1 SYNOPSIS

In your F<profile.ini>:

    [GitFlow::Init]
    commit_message = Start develop branch for first release ; default
    remote = origin git@github.com:USERNAME/%{lc}N.git ; there is no default
    config = user.email USERID@cpan.org                ; there is no default
    branch_master     = master   ; default
    branch_develop    = develop  ; default
    prefix_feature    = feature/ ; default
    prefix_release    = release/ ; default
    prefix_hotfix     = hotfix/  ; default
    prefix_support    = support/ ; default
    prefix_versiontag = v        ; default


=head1 DESCRIPTION

This plugin initializes a git repository and git-flow setting
when a new distribution is created with C<dzil new>.


=head2 Plugin options

The plugin accepts the following options:

=over 4

=item * commit_message - Defaults to C<Start develop branch for first release>

=item * config

=item * remote

=back

Above options are same as L<Dist::Zilla::Plugin::Git::Init>.
Please check original documents.

And it accepts git-flow related options:

    branch_master     = master   ; default
    branch_develop    = develop  ; default
    prefix_feature    = feature/ ; default
    prefix_release    = release/ ; default
    prefix_hotfix     = hotfix/  ; default
    prefix_support    = support/ ; default
    prefix_versiontag = v        ; default

=over 4

=item * branch_master - Defaults to C<master>

=item * branch_develop - Defaults to C<develop>

=item * prefix_feature - Defaults to C<feature/>

=item * prefix_release - Defaults to C<release/>

=item * prefix_hotfix - Defaults to C<hotfix/>

=item * prefix_support - Defaults to C<support/>

=item * prefix_versiontag - Defaults to C<v>

=back

git-flow's default prefix version tag is empty string.
But this plugin sets default as C<v>.

=head1 SEE ALSO

L<Dist::Zilla::Plugin::Git::Init>
