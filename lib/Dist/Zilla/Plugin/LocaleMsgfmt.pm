package Dist::Zilla::Plugin::LocaleMsgfmt;
# ABSTRACT: Dist::Zilla plugin that compiles Local::Msgfmt .po files to .mo files

=head1 DESCRIPTION

Put the following in your dist.ini

    [LocaleMsgfmt]
    locale = share/locale ;; (optional)

This plugin will compile all of the .po files it finds in the locale directory into .mo
files, via Locale::Msgfmt.

=head1 TODO

Remove the generated files after the build finishes, or better yet do the generation inside
the build dir.

=cut

use Locale::Msgfmt;
use Moose;
with 'Dist::Zilla::Role::BeforeBuild';

=method mvp_multivalue_args

For Config::MVP - specify setting names that may have multiple values and that will always
be stored in an arrayref

=cut

sub mvp_multivalue_args { qw(locale) }

=attr locale

=cut

has locale => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $path = File::Spec->catfile( $self->zilla->root, 'share', 'locale' );
        if ( -e $path ) {
            return [$path];
        }
        else {
            return [];
        }
    },
);

=method before_build

=cut

sub before_build {
    my ( $self, $args ) = @_;

    for my $dir ( @{ $self->locale } ) {
        my $path = Path::Class::Dir->new($dir);
        if ( -e $path ) {
            $self->log("Generating .mo files from .po files in $path");
            Locale::Msgfmt::msgfmt( { in => $path->absolute, verbose => 1, remove => 0 } );
        }
        else {
            warn "Skipping invalid path: $path";
        }
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
