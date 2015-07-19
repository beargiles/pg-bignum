/*
 * This file is released under the PostgreSQL license by its author,
 * Bear Giles <bgiles@coyotesong.com>
 */
#include <stdio.h>
#include "postgres.h"
#include "fmgr.h"
#include <postgresql/internal/c.h>
#include <openssl/bn.h>
#include <arpa/inet.h>

#include "bignum.h"

static char * bignum_to_string(BIGNUM *bn);

static BIGNUM * int4_to_bignum(int i) {
    BIGNUM *bn;
    int neg = 0;
    union {
        int i;
        const unsigned char c[sizeof(int)];
    } value;

    value.i = i;
    if (value.i < 0) {
        value.i = -value.i;
        neg = 1;
    }
    value.i = htonl(value.i);

    // convert to bignum
    bn = BN_new();
    BN_bin2bn(value.c, sizeof(int), bn);
    BN_set_negative(bn, neg);
    
    return bn;
}

static BIGNUM * int8_to_bignum(long l) {
    BIGNUM *bn;
    int neg = 0;
    union {
        long l;
        int i[2];
        const unsigned char c[sizeof(long)];
    } value;

    value.l = l;
    if (value.l < 0) {
        value.l = -value.l;
        neg = 1;
    }
    value.i[0] = htonl(value.i[0]);
    value.i[1] = htonl(value.i[1]);

    // convert to bignum
    bn = BN_new();
    BN_bin2bn(value.c, sizeof(int), bn);
    BN_set_negative(bn, neg);
    
    return bn;
}


PG_MODULE_MAGIC;

/**
 * Read from cstring
 */
PG_FUNCTION_INFO_V1(pgx_bignum_in);

Datum pgx_bignum_in(PG_FUNCTION_ARGS) {
    char *txt;
    int len;
    bytea *results;
    BIGNUM *bn;

    // check for null input
    txt = PG_GETARG_CSTRING(0);
    if (txt == NULL || strlen(txt) == 0) {
        PG_RETURN_NULL();
    }

    // convert to bignum
    bn = BN_new();
    len = BN_dec2bn(&bn, txt);

    if (strlen(txt) != len) {
        elog(ERROR, "length mismatch - non-numeric values?");
        PG_RETURN_NULL();
    }

    // write to binary format
    results = bignum_to_bytea(bn);
    BN_free(bn);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

/**
 * Write to cstring.
 */
PG_FUNCTION_INFO_V1(pgx_bignum_out);

Datum pgx_bignum_out(PG_FUNCTION_ARGS) {
    bytea *raw;
    char *results;
    BIGNUM *bn;

    // check for null value.
    raw = PG_GETARG_BYTEA_P(0);
    if (raw == NULL) {
        PG_RETURN_NULL();
    }

    bn = bytea_to_bignum(raw);
    results = bignum_to_string(bn);
    BN_free(bn);

    PG_RETURN_CSTRING(results);
}

/**
 * Read from int4
 */
PG_FUNCTION_INFO_V1(pgx_bignum_from_int4);

Datum pgx_bignum_from_int4(PG_FUNCTION_ARGS) {
    bytea *results;
    BIGNUM *bn = int4_to_bignum(PG_GETARG_INT32(0));
    results = bignum_to_bytea(bn);
    BN_free(bn);
    PG_RETURN_BYTEA_P(results);
}

/**
 * Read from int8
 */
PG_FUNCTION_INFO_V1(pgx_bignum_from_int8);

Datum pgx_bignum_from_int8(PG_FUNCTION_ARGS) {
    bytea *results;
    BIGNUM *bn = int8_to_bignum(PG_GETARG_INT64(0));
    results = bignum_to_bytea(bn);
    BN_free(bn);
    PG_RETURN_BYTEA_P(results);
}

/*************************************************************************/

/**
 * Test for equality and ordering
 */
PG_FUNCTION_INFO_V1(pgx_bignum_cmp);

Datum pgx_bignum_cmp(PG_FUNCTION_ARGS) {
    bytea *raw1, *raw2;
    BIGNUM *x, *y;
    int r;

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    raw2 = PG_GETARG_BYTEA_P(1);
    if (raw2 == NULL) {
        PG_RETURN_NULL();
    }

    x = bytea_to_bignum(raw1);
    y = bytea_to_bignum(raw2);
    r = BN_cmp(x, y); 
    
    BN_free(x);
    BN_free(y);

    PG_RETURN_INT32(r);
}

PG_FUNCTION_INFO_V1(pgx_bignum_cmp_i8);

Datum pgx_bignum_cmp_i8(PG_FUNCTION_ARGS) {
    bytea *raw1;
    BIGNUM *x, *y;
    int r;

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    y = int8_to_bignum(PG_GETARG_INT64(1));
    x = bytea_to_bignum(raw1);
    r = BN_cmp(x, y); 
    
    BN_free(x);
    BN_free(y);

    PG_RETURN_INT32(r);
}

/*************************************************************************/

/**
 * Negate value.
 */
PG_FUNCTION_INFO_V1(pgx_bignum_negate);

Datum pgx_bignum_negate(PG_FUNCTION_ARGS) {
    bytea *raw;
    BIGNUM *bn;
    bytea *results;

    // check for null values.
    raw = PG_GETARG_BYTEA_P(0);
    if (raw == NULL) {
        PG_RETURN_NULL();
    }

    bn = bytea_to_bignum(raw);
    BN_set_negative(bn, !BN_is_negative(bn));

    // write to binary format
    results = bignum_to_bytea(bn);
    BN_free(bn);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

/*************************************************************************/

/**
 * Addition
 */
PG_FUNCTION_INFO_V1(pgx_bignum_add);

Datum pgx_bignum_add(PG_FUNCTION_ARGS) {
    bytea *raw1, *raw2, *results;
    BIGNUM *x, *y;

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    raw2 = PG_GETARG_BYTEA_P(1);
    if (raw2 == NULL) {
        PG_RETURN_NULL();
    }

    x = bytea_to_bignum(raw1);
    y = bytea_to_bignum(raw2);
    BN_add(x, x, y); 

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

PG_FUNCTION_INFO_V1(pgx_bignum_add_i8);

Datum pgx_bignum_add_i8(PG_FUNCTION_ARGS) {
    bytea *raw1, *results;
    BIGNUM *x, *y;

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    y = int8_to_bignum(PG_GETARG_INT64(1));
    x = bytea_to_bignum(raw1);
    BN_add(x, x, y); 

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

/*************************************************************************/

/**
 * Subtraction
 */
PG_FUNCTION_INFO_V1(pgx_bignum_subtract);

Datum pgx_bignum_subtract(PG_FUNCTION_ARGS) {
    bytea *raw1, *raw2, *results;
    BIGNUM *x, *y;

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    raw2 = PG_GETARG_BYTEA_P(1);
    if (raw2 == NULL) {
        PG_RETURN_NULL();
    }

    x = bytea_to_bignum(raw1);
    y = bytea_to_bignum(raw2);
    BN_sub(x, x, y); 

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

PG_FUNCTION_INFO_V1(pgx_bignum_subtract_i8);

Datum pgx_bignum_subtract_i8(PG_FUNCTION_ARGS) {
    bytea *raw1, *results;
    BIGNUM *x, *y;

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    y = int8_to_bignum(PG_GETARG_INT64(1));
    x = bytea_to_bignum(raw1);
    BN_sub(x, x, y); 

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

/*************************************************************************/

/**
 * Multiplication
 */
PG_FUNCTION_INFO_V1(pgx_bignum_multiply);

Datum pgx_bignum_multiply(PG_FUNCTION_ARGS) {
    bytea *raw1, *raw2, *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    raw2 = PG_GETARG_BYTEA_P(1);
    if (raw2 == NULL) {
        PG_RETURN_NULL();
    }

    x = bytea_to_bignum(raw1);
    y = bytea_to_bignum(raw2);
    BN_mul(x, x, y, ctx);

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx); 

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

PG_FUNCTION_INFO_V1(pgx_bignum_multiply_i8);

Datum pgx_bignum_multiply_i8(PG_FUNCTION_ARGS) {
    bytea *raw1, *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    y = int8_to_bignum(PG_GETARG_INT64(1));
    x = bytea_to_bignum(raw1);
    BN_mul(x, x, y, ctx); 

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

/*************************************************************************/

/**
 * Division
 */
PG_FUNCTION_INFO_V1(pgx_bignum_divide);

Datum pgx_bignum_divide(PG_FUNCTION_ARGS) {
    bytea *raw1, *raw2, *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    raw2 = PG_GETARG_BYTEA_P(1);
    if (raw2 == NULL) {
        PG_RETURN_NULL();
    }

    y = bytea_to_bignum(raw2);
    if (BN_is_zero(y)) {
        BN_free(y);
        PG_RETURN_NULL();
    }

    x = bytea_to_bignum(raw1);
    BN_div(x, y, x, y, ctx);

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx); 

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

PG_FUNCTION_INFO_V1(pgx_bignum_divide_bi8);

Datum pgx_bignum_divide_bi8(PG_FUNCTION_ARGS) {
    bytea *raw1, *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    y = int8_to_bignum(PG_GETARG_INT64(1));
    if (BN_is_zero(y)) {
        BN_free(y);
        PG_RETURN_NULL();
    }

    x = bytea_to_bignum(raw1);
    BN_div(x, y, x, y, ctx); 

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

PG_FUNCTION_INFO_V1(pgx_bignum_divide_i8b);

Datum pgx_bignum_divide_i8b(PG_FUNCTION_ARGS) {
    bytea *raw1, *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    x = int8_to_bignum(PG_GETARG_INT64(0));

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(1);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    y = bytea_to_bignum(raw1);
    if (BN_is_zero(y)) {
        BN_free(y);
        PG_RETURN_NULL();
    }

    BN_div(x, y, x, y, ctx); 

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

/*************************************************************************/

/**
 * Modulus
 */
PG_FUNCTION_INFO_V1(pgx_bignum_modulus);

Datum pgx_bignum_modulus(PG_FUNCTION_ARGS) {
    bytea *raw1, *raw2, *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    raw2 = PG_GETARG_BYTEA_P(1);
    if (raw2 == NULL) {
        PG_RETURN_NULL();
    }

    y = bytea_to_bignum(raw2);
    if (BN_is_zero(y)) {
        BN_free(y);
        PG_RETURN_NULL();
    }

    x = bytea_to_bignum(raw1);
    BN_div(x, y, x, y, ctx);

    // write to binary format
    results = bignum_to_bytea(y);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx); 

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

PG_FUNCTION_INFO_V1(pgx_bignum_modulus_bi8);

Datum pgx_bignum_modulus_bi8(PG_FUNCTION_ARGS) {
    bytea *raw1, *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    y = int8_to_bignum(PG_GETARG_INT64(1));
    if (BN_is_zero(y)) {
        BN_free(y);
        PG_RETURN_NULL();
    }

    x = bytea_to_bignum(raw1);
    BN_div(x, y, x, y, ctx); 

    // write to binary format
    results = bignum_to_bytea(y);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

PG_FUNCTION_INFO_V1(pgx_bignum_modulus_i8b);

Datum pgx_bignum_modulus_i8b(PG_FUNCTION_ARGS) {
    bytea *raw1, *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    x = int8_to_bignum(PG_GETARG_INT64(0));

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(1);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    y = bytea_to_bignum(raw1);
    if (BN_is_zero(y)) {
        BN_free(y);
        PG_RETURN_NULL();
    }

    BN_div(x, y, x, y, ctx); 

    // write to binary format
    results = bignum_to_bytea(y);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

/*************************************************************************/

/**
 * GCD
 */
PG_FUNCTION_INFO_V1(pgx_bignum_gcd);

Datum pgx_bignum_gcd(PG_FUNCTION_ARGS) {
    bytea *raw1, *raw2, *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    raw2 = PG_GETARG_BYTEA_P(1);
    if (raw2 == NULL) {
        PG_RETURN_NULL();
    }

    y = bytea_to_bignum(raw2);
    if (BN_is_zero(y)) {
        BN_free(y);
        PG_RETURN_NULL();
    }

    x = bytea_to_bignum(raw1);
    BN_gcd(x, x, y, ctx);

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx); 

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

PG_FUNCTION_INFO_V1(pgx_bignum_gcd_i8);

Datum pgx_bignum_gcd_i8(PG_FUNCTION_ARGS) {
    bytea *raw1, *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    // check for null values.
    raw1 = PG_GETARG_BYTEA_P(0);
    if (raw1 == NULL) {
        PG_RETURN_NULL();
    }

    y = int8_to_bignum(PG_GETARG_INT64(1));
    if (BN_is_zero(y)) {
        BN_free(y);
        PG_RETURN_NULL();
    }

    x = bytea_to_bignum(raw1);
    BN_gcd(x, x, y, ctx); 

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

PG_FUNCTION_INFO_V1(pgx_bignum_gcd_ii);

Datum pgx_bignum_gcd_ii(PG_FUNCTION_ARGS) {
    bytea *results;
    BIGNUM *x, *y;
    BN_CTX *ctx = BN_CTX_new();

    y = int8_to_bignum(PG_GETARG_INT64(1));
    if (BN_is_zero(y)) {
        BN_free(y);
        PG_RETURN_NULL();
    }

    x = int8_to_bignum(PG_GETARG_INT64(0));
    BN_gcd(x, x, y, ctx); 

    // write to binary format
    results = bignum_to_bytea(x);
    BN_free(x);
    BN_free(y);
    BN_CTX_free(ctx);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

/*************************************************************************/

/**
 * Absolute value.
 */
PG_FUNCTION_INFO_V1(pgx_bignum_abs);

Datum pgx_bignum_abs(PG_FUNCTION_ARGS) {
    bytea *raw;
    BIGNUM *bn;
    bytea *results;

    // check for null values.
    raw = PG_GETARG_BYTEA_P(0);
    if (raw == NULL) {
        PG_RETURN_NULL();
    }

    bn = bytea_to_bignum(raw);
    BN_set_negative(bn, 0);

    // write to binary format
    results = bignum_to_bytea(bn);
    BN_free(bn);

    // return bytea
    PG_RETURN_BYTEA_P(results);
}

/*************************************************************************/

/**
 * Convert BIGNUM to bytea to BIGNUM
 */
BIGNUM * bytea_to_bignum(bytea *raw) {
    BIGNUM *bn = BN_new();

    if (VARSIZE(raw) == VARHDRSZ) {
        BN_zero(bn);
    } else {
        bn = BN_bin2bn((const unsigned char *) VARDATA(raw) + 1, VARSIZE(raw) - VARHDRSZ - 1, NULL);
        BN_set_negative(bn, (*VARDATA(raw) & 0x01) == 0x01);
    }

    return bn;
}

/**
 * Convert BIGNUM to bytea.
 */
bytea * bignum_to_bytea(BIGNUM *bn) {
    int len;
    bytea *results;

    // create bytea results.
    len = BN_num_bytes(bn);
    results = (bytea *) palloc(len + 1 + VARHDRSZ);
    *VARDATA(results) = BN_is_negative(bn) ? 0x01 : 0x00;
    BN_bn2bin(bn, (unsigned char *) VARDATA(results) + 1);
    SET_VARSIZE(results, len + 1 + VARHDRSZ);

    return results;
}

/**
 * Convert to cstring.
 */
static char * bignum_to_string(BIGNUM *bn) {
    char *ptr, *results;
    int len;

    // convert bignum to decimal
    ptr = BN_bn2dec(bn);

    // create bytea results.
    len = strlen(ptr);
    results = palloc (1 + len);
    strncpy(results, ptr, len);
    results[len] = '\0';

    // release memory
    OPENSSL_free(ptr);

    return results;
}

/**
 * Convert BIGNUM to Datum (for return in records).
 */
Datum BnGetDatum(BIGNUM *bn) {
    return PointerGetDatum(bignum_to_bytea(bn));
}
