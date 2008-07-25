#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define NEED_sv_2pv_flags
#include "ppport.h"

#include <uuid/uuid.h>

#define UUID_TYPE_DCE 2
#define UUID_TYPE_TIME 1
#define UUID_TYPE_RANDOM 4

#define UUID_STRING_SIZE 36

typedef char uuid_str_buf[UUID_STRING_SIZE + 1];

/* FIXME uuid_time, uuid_type, uuid_variant are available in libuuid but not in
 * darwin's uuid.h... consider exposing? */

/* generates a new UUID of a given version */
STATIC void new_uuid (IV version, uuid_t uuid) {
    switch (version) {
        case UUID_TYPE_TIME:
            uuid_generate_time(uuid);
            break;
        case UUID_TYPE_RANDOM:
            uuid_generate_random(uuid);
            break;
        case UUID_TYPE_DCE:
        default:
            uuid_generate(uuid);
    }
}

/* hex or binary sv to uuid_t */
STATIC IV sv_to_uuid (SV *sv, uuid_t uuid) {
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


MODULE = Data::UUID::LibUUID            PACKAGE = Data::UUID::LibUUID
PROTOTYPES: ENABLE

SV*
uuid_eq(uu1_sv, uu2_sv)
    SV *uu1_sv;
    SV *uu2_sv;
    PROTOTYPE: $$
    PREINIT:
        uuid_t uu1;
        uuid_t uu2;
    PPCODE:
        if ( sv_to_uuid(uu1_sv, uu1) && sv_to_uuid(uu2_sv, uu2) )
            if ( uuid_compare(uu1, uu2) == 0 )
                XSRETURN_YES;
            else
                XSRETURN_NO;
        else
            XSRETURN_UNDEF;

SV*
uuid_compare(uu1_sv, uu2_sv)
    SV *uu1_sv;
    SV *uu2_sv;
    PROTOTYPE: $$
    PREINIT:
        uuid_t uu1;
        uuid_t uu2;
    PPCODE:
        if ( sv_to_uuid(uu1_sv, uu1) && sv_to_uuid(uu2_sv, uu2) )
            XSRETURN_IV(uuid_compare(uu1, uu2));
        else
            XSRETURN_UNDEF;

SV*
new_uuid_binary(...)
    PROTOTYPE: ;$
    PREINIT:
        uuid_t uuid;
        IV version = UUID_TYPE_DCE;
    PPCODE:
        if ( items == 1 ) version = SvIV(ST(0));

        new_uuid(version, uuid);

        XSRETURN_PVN((char *)uuid, sizeof(uuid));

SV*
new_uuid_string(...)
    PROTOTYPE: ;$
    PREINIT:
        uuid_t uuid;
        IV version = UUID_TYPE_DCE;
        uuid_str_buf buf;
    PPCODE:
        if ( items == 1 ) version = SvIV(ST(0));

        new_uuid(version, uuid);
        uuid_unparse(uuid, buf);

        XSRETURN_PVN(buf, UUID_STRING_SIZE);

SV*
uuid_to_string(bin)
    SV *bin
    PROTOTYPE: $
    PREINIT:
        uuid_t uuid;
        uuid_str_buf buf;
    PPCODE:
        if ( sv_to_uuid(bin, uuid) ) {
            uuid_unparse(uuid, buf);
            XSRETURN_PVN(buf, UUID_STRING_SIZE);
        } else
            XSRETURN_UNDEF;

SV*
uuid_to_binary(str)
    SV *str
    PROTOTYPE: $
    PREINIT:
        uuid_t uuid;
    PPCODE:
        if ( sv_to_uuid(str, uuid) )
            XSRETURN_PVN((char *)uuid, sizeof(uuid));
        else
            XSRETURN_UNDEF;

SV*
new_dce_uuid_binary(...)
    PREINIT:
        uuid_t uuid;
    PPCODE:
        uuid_generate(uuid);
        XSRETURN_PVN((char *)uuid, sizeof(uuid));

SV*
new_dce_uuid_string(...)
    PREINIT:
        uuid_t uuid;
        uuid_str_buf buf;
    PPCODE:
        uuid_generate(uuid);
        uuid_unparse(uuid, buf);
        XSRETURN_PVN(buf, UUID_STRING_SIZE);


