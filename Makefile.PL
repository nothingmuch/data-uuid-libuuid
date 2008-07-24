#!/usr/bin/perl -w

use strict;

use ExtUtils::MakeMaker;

my $conf = WriteMakefile(
	NAME         => 'Data::UUID::LibUUID',
	VERSION_FROM => 'lib/Data/UUID/LibUUID.pm',
	INSTALLDIRS  => 'site',
	SIGN         => 1,
	PL_FILES     => { },
    LIBS         => [ "-luuid" ],
	PREREQ_PM    => {
		'Test::use::ok' => 0,
        'Test::More' => 0,
        'Sub::Exporter' => 0,
	},
);

if ( system(join " ", $conf->{CC}, '-c', $conf->{CCFLAGS}, $conf->{INC} || '', "hdr_check.h") != 0 ) {
    warn "<uuid/uuid.h> seems to be missing, please install e2fsprogs' "
       . "libuuid, or uuid-dev on debian based linux distributions\n";

    exit 1;
}
