#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define NEED_sv_2pv_flags
#include "ppport.h"

#include <uuid/uuid.h>

#define UUID_STRING_SIZE 36

/* FIXME uuid_time, uuid_type, uuid_variant are available in libuuid but not in
 * darwin's uuid.h... consider exposing? */

/* generates a new UUID of a given version */
STATIC void new_uuid (int version, uuid_t uuid) {
	switch (version) {
		case 1:
			uuid_generate_time(uuid);
			break;
		case 4:
			uuid_generate_random(uuid);
			break;
		case 2:
		default:
			uuid_generate(uuid);
	}
}

/* hex or binary sv to uuid_t */
STATIC int sv_to_uuid (SV *sv, uuid_t uuid) {
    if ( SvPOK(sv) || sv_isobject(sv) ) {
        char *pv;
        STRLEN len;

        if ( SvPOK(sv) ) {
            pv = SvPV_nolen(sv);
            len = SvCUR(sv);
        } else {
            pv = SvPV(sv, len);
        }

        switch ( len ) {
            case sizeof(uuid_t):
                uuid_copy(uuid, *(uuid_t *)pv);
                return 1;
            case UUID_STRING_SIZE:
                if ( uuid_parse(pv, uuid) == 0 )
                    return 1;
        }
    }

	return 0;
}


MODULE = Data::UUID::LibUUID			PACKAGE = Data::UUID::LibUUID
PROTOTYPES: ENABLE

SV*
uuid_eq(uu1_sv, uu2_sv)
    SV *uu1_sv;
    SV *uu2_sv;
	PROTOTYPE: $$
	PREINIT:
		uuid_t uu1;
        uuid_t uu2;
	CODE:
		if ( sv_to_uuid(uu1_sv, uu1) && sv_to_uuid(uu2_sv, uu2) )
			RETVAL = ( uuid_compare(uu1, uu2) == 0 ? &PL_sv_yes : &PL_sv_no );
        else
			RETVAL = &PL_sv_undef;
	OUTPUT:
		RETVAL


SV*
uuid_compare(uu1_sv, uu2_sv)
    SV *uu1_sv;
    SV *uu2_sv;
	PROTOTYPE: $$
	PREINIT:
		uuid_t uu1;
        uuid_t uu2;
	CODE:
		if ( sv_to_uuid(uu1_sv, uu1) && sv_to_uuid(uu2_sv, uu2) )
			RETVAL = newSViv(uuid_compare(uu1, uu2));
        else
			RETVAL = &PL_sv_undef;
	OUTPUT:
		RETVAL

SV*
new_uuid_binary(...)
	PROTOTYPE: ;$
	PREINIT:
		uuid_t uuid;
		int version = 2; /* DCE */
	CODE:
		if ( items == 1 ) version = SvIV(ST(0));

		new_uuid(version, uuid);

		RETVAL = newSVpvn((char *)uuid, sizeof(uuid));
	OUTPUT:
		RETVAL

SV*
new_uuid_string(...)
	PROTOTYPE: ;$
	PREINIT:
		uuid_t uuid;
		int version = 2; /* DCE */
		char buf[37];
	CODE:
		if ( items == 1 ) version = SvIV(ST(0));

		new_uuid(version, uuid);
		uuid_unparse(uuid, buf);

		RETVAL = newSVpvn(buf, UUID_STRING_SIZE);
	OUTPUT:
		RETVAL

SV*
uuid_to_string(bin)
	SV *bin
	PROTOTYPE: $
	PREINIT:
		uuid_t uuid;
		char buf[37];
	CODE:
		if ( sv_to_uuid(bin, uuid) ) {
			uuid_unparse(uuid, buf);
			RETVAL = newSVpvn(buf, UUID_STRING_SIZE);
		} else
			RETVAL = &PL_sv_undef;
	OUTPUT:
		RETVAL

SV*
uuid_to_binary(str)
	SV *str
	PROTOTYPE: $
	PREINIT:
		uuid_t uuid;
	CODE:
        if ( sv_to_uuid(str, uuid) )
			RETVAL = newSVpvn((char *)uuid, sizeof(uuid));
		else
            RETVAL = &PL_sv_undef;
	OUTPUT:
		RETVAL
