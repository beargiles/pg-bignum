#ifndef bignum_h
#define bignum_h

#include <openssl/bn.h>

#ifdef __cplusplus
extern "C" {
#endif

BIGNUM * bytea_to_bignum(bytea *raw);
bytea * bignum_to_bytea(BIGNUM *bn);

// big numbers
Datum pgx_bignum_in(PG_FUNCTION_ARGS);
Datum pgx_bignum_out(PG_FUNCTION_ARGS);

Datum BnGetDatum(BIGNUM *bn);

#ifdef __cplusplus
}
#endif

#endif