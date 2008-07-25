#!/usr/bin/perl

use strict;
use warnings;

BEGIN {
    if ( -e "blib" ) {
        eval "use blib";
    }

    eval 'use Data::UUID';
    eval 'use Data::GUID';
    eval 'use Data::UUID::LibUUID qw(new_dce_uuid_binary new_dce_uuid_string new_uuid_binary new_uuid_string)';
    eval 'use UUID';
    eval 'use OSSP::uuid qw(uuid_make uuid_create uuid_export uuid_destroy UUID_MAKE_V1 UUID_MAKE_V4 UUID_FMT_STR)';
    die $@ if $@;
}

use Benchmark qw(cmpthese);

our $uuidgen = Data::UUID->new;

cmpthese(-0.5, {
    ( exists $INC{"Data/UUID/LibUUID.pm"} ? (
    'libuuid no proto bin' => 'new_dce_uuid_binary()',
    'libuuid no proto str' => 'new_dce_uuid_string()',
    'libuuid version bin' => 'new_uuid_binary()',
    'libuuid version str' => 'new_uuid_string()', ) : () ),
    ( exists $INC{"Data/GUID.pm"} ? (
    'Data::GUID obj' => 'Data::GUID->new',
    'Data::GUID bin' => 'Data::GUID->new->as_binary',
    'Data::GUID str' => 'Data::GUID->new->as_string', ) : () ),
    ( exists $INC{"Data/UUID.pm"} ? (
    'Data::UUID bin' => '$uuidgen->create_bin',
    'Data::UUID str' => '$uuidgen->create_str', ) : () ),
    ( exists $INC{"UUID.pm"} ? (
    'UUID bin' => 'UUID::generate(my $x)',
    'UUID str' => 'UUID::generate(my $x); UUID::unparse($x, my $str)', ) : () ),
    ( exists $INC{"OSSP/uuid.pm"}  ? (
    'OSSP obj' => 'my $x = OSSP::uuid->new; $x->make("v4")',
    'OSSP bin v1' => 'uuid_create(my $x); uuid_make($x, UUID_MAKE_V1()); uuid_destroy($x)',
    'OSSP bin v4' => 'uuid_create(my $x); uuid_make($x, UUID_MAKE_V4()); uuid_destroy($x)',
    'OSSP make str' => 'uuid_create(my $x); uuid_make($x, UUID_MAKE_V1()); uuid_export($x, UUID_FMT_STR(), my $str, undef); uuid_destroy($x)', ) : () ),
});

