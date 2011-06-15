package Dist::Zilla::Plugin::GitFlow::NextVersion;
# ABSTRACT: provide a version number by bumping the last git flow release tag

use 5.010;

use Dist::Zilla 4 ();
use Git::Wrapper;
use Version::Next ();
use Try::Tiny;
use version 0.80 ();

use Moose;
use namespace::autoclean 0.09;

with 'Dist::Zilla::Role::VersionProvider';

# -- attributes

has version_regexp => (
    is      => 'ro',
    isa     => 'Str',
    default => '^v(.+)$'
);

has first_version => (
    is      => 'ro',
    isa     => 'Str',
    default => '0.001'
);

# -- role implementation

sub provide_version {
  my ($self) = @_;

  # override (or maybe needed to initialize)
  return $ENV{V} if exists $ENV{V};

  local $/ = "\n"; # Force record separator to be single newline

  my $git  = Git::Wrapper->new('.');
  my $regexp = $self->version_regexp;

  my @tags = $git->tag;
  return $self->first_version unless @tags;

  # find highest version from tags
  my ($last_ver) =  sort { version->parse($b) <=> version->parse($a) }
  grep { eval { version->parse($_) }  }
  map  { /$regexp/ ? $1 : ()          } @tags;

  $self->log_fatal("Could not determine last version from tags")
  unless defined $last_ver;

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
            return $self->zilla->version("$last_ver");
        }
    }

  my $new_ver = Version::Next::next_version($last_ver);
  $self->log("Bumping version from $last_ver to $new_ver");

  $self->zilla->version("$new_ver");
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
__END__

=for Pod::Coverage
    provide_version

=head1 SYNOPSIS

In your F<dist.ini>:

    [GitFlow::NextVersion]
    first_version = 0.001    ; this is the default
    version_regexp = ^v(.+)$ ; this is the default

When you want to release the module on the develop branch:

    $ git flow release start 0.003
    #
    # edit and commit
    #
    $ git flow release finish 0.003

After finishing release, then upload your released module:

    $ git checkout v0.003
    $ dzil release # this will be done with Dist::Zilla::Plugin::UploadToCPAN

If you want to make specific version module tarball:

    $ git checkout v0.002
    $ dzil build

=head1 DESCRIPTION

This does the L<Dist::Zilla::Role::VersionProvider> role. It finds the last
version number from your git tags, increments it using L<Version::Next>, and
uses the result as the C<version> parameter for your distribution.

The plugin accepts the following options:

=over

=item *

C<first_version> - Defaults to C<0.001>

=item *

C<version_regexp> - Defaults to C<^v(.+)$>

=back

Above options are same as L<Dist::Zilla::Plugin::Git::NextVersion>.
Please check original documents.

You can also set the C<V> environment variable to override the new version.
This is useful if you need to bump to a specific version. For example, if
the last tag is 0.005 and you want to jump to 1.000 you can set V = 1.000.

    $ V=1.000 dzil build
    $ V=1.000 dzil release

=cut

=head1 SEE ALSO

L<Dist::Zilla::Plugin::Git::NextVersion>
