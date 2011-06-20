package Dist::Zilla::Plugin::GitFlow;
# ABSTRACT: develop perl modules with git-flow and Dist::Zilla

use 5.008;
use strict;
use warnings;

use Dist::Zilla 2.100880;    # Need mvp_multivalue_args in Plugin role
1;

=head1 SYNOPSIS

In your F<dist.ini>:

    [@GitFlow]

When you want to release the module on the develop branch:

    $ git flow release start 0.003
    #
    # edit and commit
    #
    $ dzil release
    $ git flow release finish 0.003

After finishing release, then upload your released module:

    $ git checkout v0.003
    $ dzil build
    $ cpan-upload YourModule-0.003.tar.gz

If you want to make specific version module tarball:

    $ git checkout v0.002
    $ dzil build


=head1 DESCRIPTION

This set of plugins for L<Dist::Zilla> can do interesting things for
module authors using L<git|http://git- scm.com> to track their work. The
following plugins are provided in this distribution:

=over 4

=item * L<Dist::Zilla::Plugin::GitFlow::Init>

=item * L<Dist::Zilla::Plugin::GitFlow::NextVersion>

=item * L<Dist::Zilla::Plugin::GitFlow::NextRelease>

=back

It also provice plugin bundle:

=over 4

=item * L<Dist::Zilla::PluginBundle::GitFlow>

=back

This plugin use it's own next version and next release module,
so do not use original L<Dist::Zilla::Plugin::NextRelease>
and L<Dist::Zilla::Plugin::NextVersion> plugins.

=head1 SEE ALSO

I stolen almost code from L<Dist::Zilla::Plugin::Git>.
Please check original code.

=over 4

=item * L<Dist::Zilla::Plugin::Git>

=item * L<Dist::Zilla::Plugin::NextVersion>

=item * L<Dist::Zilla::Plugin::NextRelease>

=back

You can look for information on this module at:

=over 4

=item * A successful Git branching model

L<http://nvie.com/posts/a-successful-git-branching-model/>

=item * git-flow git repository

L<https://github.com/nvie/gitflow>

=item * See open / report bugs

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dist-Zilla-Plugin-GitFlow>

=item * Git repository

L<http://github.com/jquelin/dist-zilla-plugin-git>

=back
