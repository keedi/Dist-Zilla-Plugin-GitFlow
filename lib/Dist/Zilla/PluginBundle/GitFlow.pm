package Dist::Zilla::PluginBundle::GitFlow;
# ABSTRACT: all git-flow plugins in one go

use Moose;
use Class::MOP;

with 'Dist::Zilla::Role::PluginBundle';

my @bundled_plugins = qw/
    GitFlow::NextVersion
    GitFlow::NextRelease
    Git::Check
    Git::Commit
/;

my %multi;
for my $name (@bundled_plugins) {
    my $class = "Dist::Zilla::Plugin::$name";
    Class::MOP::load_class($class);
    @multi{ $class->mvp_multivalue_args } = ();
}

sub mvp_multivalue_args { keys %multi; }

sub bundle_config {
    my ($self, $section) = @_;
    my $arg   = $section->{payload};

    my @config;

    for my $name (@bundled_plugins) {
        my $class = "Dist::Zilla::Plugin::$name";
        my %payload;
        if ($name eq 'Git::Commit') {
            $payload{'commit_msg'} = 'Bump up to v%v%n%n%c';
        }
        foreach my $k (keys %$arg) {
            $payload{$k} = $arg->{$k} if $class->can($k);
        }
        push @config, [ "$section->{name}/$name" => $class => \%payload ];
    }

    return @config;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
__END__

=for Pod::Coverage
    mvp_multivalue_args
    bundle_config

=head1 SYNOPSIS

In your F<dist.ini>:

    [@GitFlow]

If you want to change C<first_version>:

    [@GitFlow]
    first_version = 0.0.1

=head1 DESCRIPTION

This is a plugin bundle to load git-flow and git plugins.
It is equivalent to:

    [GitFlow::NextVersion]
    [GitFlow::NextRelease]
    [Git::Check]
    [Git::Commit]
    commit_msg = Bump up to v%v%n%n%c ; default

It uses L<Dist::Zilla::Plugin::GitFlow::NextRelease>
and L<Dist::Zilla::Plugin::GitFlow::NexvVersion>
rather than L<Dist::Zilla::Plugin::NextRelease>
and L<Dist::Zilla::Plugin::NextVersion>.

It includes the following plugins with their default configuration
except L<Git::Commit>:

=over 4

=item *

L<Dist::Zilla::Plugin::GitFlow::NextVersion>

=item *

L<Dist::Zilla::Plugin::GitFlow::NextRelease>

=item *

L<Dist::Zilla::Plugin::Git::Check>

=item *

L<Dist::Zilla::Plugin::Git::Commit>

=back
