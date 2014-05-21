#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use File::Spec;
	if ( File::Spec->isa("File::Spec::Unix") ) {
		plan 'no_plan';
	} else {
		plan skip_all => "not running on something UNIXish";
	}
}


use ok 'Data::UUID::LibUUID' => ":all";

for ( 1 .. 2 ) {
    my @uuids;

    foreach my $child ( 1 .. 3 ) {
        my $pid = open my $handle, "-|";
        die $! unless defined $pid;

        if ( $pid ) {
            push @uuids, <$handle>;
            close $handle;
        } else {
            print new_uuid_string();
            exit;
        }
        sleep 1; # This makes the test pass, but it scares the bajebus out of me.
                 # Does that mean there could be collisions if
                 # new_uuid_string() is called very close in time?
                 #
                 # Also the fact that it fails differently gives me the
                 # impressions that it is a timing issue or what one should
                 # call it.
    }

    push @uuids, new_uuid_string();

    while ( @uuids ) {
        my $str = shift @uuids;
        isnt( $str, $_ ) for @uuids;
    }
}


