#!/usr/bin/perl

package Data::UUID::LibUUID;

use strict;

use vars qw($VERSION @ISA);

$VERSION = '0.02';

use Sub::Exporter -setup => {
    exports => [qw(
        new_uuid_string new_uuid_binary
        
        uuid_to_binary uuid_to_string
        
        uuid_eq uuid_compare
    )],
    groups => {
        default => [qw(new_uuid_string new_uuid_binary uuid_eq)],
    },
};

eval {
    require XSLoader;
    XSLoader::load('Data::UUID::LibUUID', $VERSION);
    1;
} or do {
    require DynaLoader;
    push @ISA, 'DynaLoader';
    bootstrap Data::UUID::LibUUID $VERSION;
};

__PACKAGE__

__END__

=pod

=head1 NAME

Data::UUID::LibUUID - F<uuid.h> based UUID generation (versions 1, 2 and 4)

=head1 SYNOPSIS

	use Data::UUID::LibUUID;

    my $uuid = new_uuid_string();

=head1 DESCRIPTION

This module provides bindings for libuuid shipped with e2fsprogs or uuid-dev on
debian, and also works with the system F<uuid.h> on darwin.

=head1 EXPORTS

=over 4

=item new_uuid_string $version

=item new_uuid_binary $version

Returns a new UUID in string (dash separated hex) or binary (16 octets) format.

C<$version> can be 1, 2, or 4 and defaults to 2.

Version 1 is timestamp/MAC based UUIDs, like L<Data::UUID> provides. They
reveal time and host information, so they may be considered a security risk.

Version 2 is described here
L<http://www.opengroup.org/onlinepubs/9696989899/chap5.htm#tagcjh_08_02_01_01>

Version 4 is based just on random data. This is not guaranteed to be high
quality random data.

=item uuid_to_binary $str_or_bin

Converts a UUID from string or binary format to binary format.

Returns undef on a non UUID argument.

=item uuid_to_string $str_or_bin

Converts a UUID from string or binary format to string format.

Returns undef on a non UUID argument.

=item uuid_eq $str_or_bin, $str_or_bin

Checks if two UUIDs are equivalent. Returns true if they are, or false if they aren't.

Returns undef on non UUID arguments.

=item uuid_compare $str_or_bin, $str_or_bin

Returns -1, 0 or 1 depending on the lexicographical order of the UUID. This
works like the C<cmp> builtin.

Returns undef on non UUID arguments.

=back

=head1 TODO

=over 4

=item *

Consider bundling libuuid for when no system C<uuid.h> exists.

=back

=head1 SEE ALSO

L<Data::GUID>, L<Data::UUID>, L<UUID>, L<http://e2fsprogs.sourceforge.net/>

=head1 VERSION CONTROL

This module is maintained using Darcs. You can get the latest version from
L<http://nothingmuch.woobling.org/code>, and use C<darcs send> to commit
changes.

=head1 AUTHOR

Yuval Kogman E<lt>nothingmuch@woobling.orgE<gt>

=head1 COPYRIGHT

	Copyright (c) 2008 Yuval Kogman. All rights reserved
	This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=cut
