package MooseX::Storage::MaybeDeferred;

use strict;
use warnings;
use namespace::autoclean;
use MooseX::Role::Parameterized;

our $VERSION = '0.0.1';

parameter 'default_format' => (
    isa      => 'Defined',
    required => 1,
);

parameter 'default_io' => (
    isa      => 'Defined',
    required => 1,
);

role {
    with 'MooseX::Storage::Deferred';

    my $p = shift;

    around 'thaw' => sub {
        my $orig        = shift;
        my $self        = shift;
        my $packed      = shift;
        my $type        = shift;
        $type->{format} = $p->default_format unless exists $type->{format};

        $self->$orig($packed, $type, @_);
    };
    around 'freeze' => sub {
        my $orig        = shift;
        my $self        = shift;
        my $type        = shift;
        $type->{format} = $p->default_format unless exists $type->{format};

        $self->$orig($type, @_);

    };
    around 'load' => sub {
        my $orig     = shift;
        my $self     = shift;
        my $filename = shift;
        my $type     = shift;
        $type->{io}  = $p->default_io unless exists $type->{io};

        $self->$orig($filename, $type, @_);
    };
    around 'store' => sub {
        my $orig     = shift;
        my $self     = shift;
        my $filename = shift;
        my $type     = shift;
        $type->{io}  = $p->default_io unless exists $type->{io};

        $self->$orig($filename, $type, @_);

    };
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

MooseX::Storage::MaybeDeferred - A role for the less indecesive programmers

=head1 VERSION

0.0.1

=head1 SYNOPSIS

    package Point;
    use Moose;
    use MooseX::Storage;

    with MooseX::Storage::MaybeDeferred => {
        default_format => 'JSON',
        default_io     => 'File',
    };

    has 'x' => (is => 'rw', isa => 'Int');
    has 'y' => (is => 'rw', isa => 'Int');

    1;

    my $p = Point->new();
    $p->freeze();
    # or
    $p->freeze({format => 'Storable'});

    ...

    $p->store($filename);
    $p->store($filename, {format => 'Storable', io => 'AtomicFile'});

    ...

    my $another_point;
    $another_point = Point->load($filename);
    # or
    $another_point = Point->load($filename, {format => 'JSON', io => 'File'});

=head1 DESCRIPTION

This Module shoud give you the benefits of having a hard coded format and io as usually used
with L<MooseX::Storage> but still offers you the flexibility to change the io and format
layer dynamically. It therefor uses L<MooseX::Storage::Deferred>.

=head1 SEE ALSO

=over

=item L<MooseX::Storage>

=item L<MooseX::Storage::Deferred>

=back

=head1 ACKNOWLEDGEMENTS

Thanks L<www.netdescribe.com>.

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Martin Barth.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

