#!/usr/bin/perl -w

use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
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

