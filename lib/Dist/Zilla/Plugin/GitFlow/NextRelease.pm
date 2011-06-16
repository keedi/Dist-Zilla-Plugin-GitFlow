package Dist::Zilla::Plugin::GitFlow::NextRelease;
# ABSTRACT: update the next release number in your changelog

use Moose;
use namespace::autoclean;

use Try::Tiny;

extends 'Dist::Zilla::Plugin::NextRelease';

has version_regexp => (
    is      => 'ro',
    isa     => 'Str',
    default => '^v(.+)$'
);

sub _on_version_tag {
    my $self = shift;

    my $git  = Git::Wrapper->new('.');
    my $regexp = $self->version_regexp;

    my $branch = try {
        my $ref = ( $git->symbolic_ref('HEAD') )[0];
        $ref =~ s|^refs/heads/||;
        $ref;
    };

    if (!$branch) {
        my $version = try {
            ( $git->describe( '--exact-match', 'HEAD' ) )[0];
        };

        if ( $version
            && $version =~ /$regexp/
            && eval { version->parse($version) } )
        {
            return 1;
        }
    }

    return;
}

around munge_files => sub {
    my $orig = shift;
    my $self = shift;

    if ( $self->_on_version_tag ) {
        my ($file) = grep { $_->name eq $self->filename } @{ $self->zilla->files };
        return unless $file;

        my $delim = $self->delim;
        my $content = $file->content;
        $content =~ s{ (\Q$delim->[0]\E \s*) \$NEXT (\s* \Q$delim->[1]\E) \n }{}xs;
        $content = $self->fill_in_string(
            $content,
            {
                dist    => \( $self->zilla ),
                version => \( $self->zilla->version ),
                NEXT    => \( $self->section_header ),
            },
        );

        $self->log_debug([ 'updating contents of %s in memory', $file->name ]);
        $file->content($content);
    }
    else {
        $self->$orig(@_);
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;
__END__

=for Pod::Coverage
    munge_files

=head1 SYNOPSIS

In your F<dist.ini>:

    [GitFlow::NextRelease]

In your F<Changes> file:

  {{$NEXT}}

=head1 DESCRIPTION

This plugin is almost same as L<Dist::Zilla::Plugin::NextRelease>
except when execute C<dzil build> on release tagged reference.

=head2 Plugin options

The plugin accepts the following options:

=over 4

=item filename - defaults to F<Changes>

=item update_filename - defaults to the C<filename>

=item format - defaults to C<%-9v %{yyyy-MM-dd HH:mm:ss VVVV}d>

=item time_zone - defaults to I<local>

=back

Above options are same as L<Dist::Zilla::Plugin::NextRelease>.
Please check original documents.

And it accepts additional options:

=over 4

=item * version_regexp - This value must be same as L<Dist::Zilla::Plugin::GitFlow::NextVersion>'s C<version_regexp> value; Defaults to C<^v(.+)0$>

=back

=head1 SEE ALSO

L<Dist::Zilla::Plugin::Git::NextVersion>
