/*
 * Author: Bear Giles <bgiles@coyotesong.com>
 * Created at: 2015-07-18 18:03:42 -0600
 */

--
-- create type
--
CREATE TYPE bignum;

CREATE OR REPLACE FUNCTION bn_in(cstring)
RETURNS bignum
AS 'bignum', 'pgx_bignum_in'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_out(bignum)
RETURNS CSTRING
AS 'bignum', 'pgx_bignum_out'
LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE bignum (
    INPUT   = bn_in,
    OUTPUT  = bn_out
);

--
-- create casts
--
CREATE OR REPLACE FUNCTION bn_from_int4(int4) RETURNS bignum
AS 'bignum', 'pgx_bignum_from_int4'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_from_int8(int8) RETURNS bignum
AS 'bignum', 'pgx_bignum_from_int8'
LANGUAGE C IMMUTABLE STRICT;

CREATE CAST (int4 AS bignum) WITH FUNCTION bn_from_int4(int4) AS ASSIGNMENT;

CREATE CAST (int8 AS bignum) WITH FUNCTION bn_from_int8(int8) AS ASSIGNMENT;

--
-- create functions for equality
--
CREATE OR REPLACE FUNCTION bn_cmp(bignum, bignum) RETURNS int
AS 'bignum', 'pgx_bignum_cmp'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_cmp(bignum, int8) RETURNS int
AS 'bignum', 'pgx_bignum_cmp_i8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_eq(bignum, bignum) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) = 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_eq(bignum, int8) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) = 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_eq(int8, bignum) RETURNS bool AS $$
   SELECT bn_cmp($2, $1) = 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_ne(bignum, bignum) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) <> 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_ne(bignum, int8) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) <> 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_ne(int8, bignum) RETURNS bool AS $$
   SELECT bn_cmp($2, $1) <> 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OPERATOR = (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_eq,
   NEGATOR = <>,
   COMMUTATOR = =,
   HASHES,
   MERGES
);

CREATE OPERATOR = (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_eq,
   NEGATOR = <>,
   COMMUTATOR = =,
   HASHES,
   MERGES
);

CREATE OPERATOR = (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_eq,
   NEGATOR = <>,
   COMMUTATOR = =,
   HASHES,
   MERGES
);

CREATE OPERATOR <> (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_ne,
   NEGATOR = =,
   COMMUTATOR = <>
 );

CREATE OPERATOR <> (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_ne,
   NEGATOR = =,
   COMMUTATOR = <>
 );

CREATE OPERATOR <> (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_ne,
   NEGATOR = =,
   COMMUTATOR = <>
 );
 
--
-- create functions for ordering
--
CREATE OR REPLACE FUNCTION bn_lt(bignum, bignum) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) < 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_lt(bignum, int8) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) < 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_lt(int8, bignum) RETURNS bool AS $$
   SELECT bn_cmp($2, $1) > 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_le(bignum, bignum) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) <= 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_le(bignum, int8) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) <= 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_le(int8, bignum) RETURNS bool AS $$
   SELECT bn_cmp($2, $1) >= 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_ge(bignum, bignum) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) >= 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_ge(bignum, int8) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) >= 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_ge(int8, bignum) RETURNS bool AS $$
   SELECT bn_cmp($2, $1) <= 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_gt(bignum, bignum) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) > 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_gt(bignum, int8) RETURNS bool AS $$
   SELECT bn_cmp($1, $2) > 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_gt(int8, bignum) RETURNS bool AS $$
   SELECT bn_cmp($2, $1) < 0;
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OPERATOR < (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_lt,
   NEGATOR = >=
);

CREATE OPERATOR < (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_lt,
   NEGATOR = >=
);

CREATE OPERATOR < (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_lt,
   NEGATOR = >=
);

CREATE OPERATOR <= (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_le,
   NEGATOR = >
);

CREATE OPERATOR <= (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_le,
   NEGATOR = >
);
CREATE OPERATOR <= (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_le,
   NEGATOR = >
);
 
CREATE OPERATOR >= (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_ge,
   NEGATOR = <
);
 
CREATE OPERATOR >= (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_ge,
   NEGATOR = <
);
 
CREATE OPERATOR >= (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_ge,
   NEGATOR = <
);

CREATE OPERATOR > (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_gt,
   NEGATOR = <=
);

CREATE OPERATOR > (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_gt,
   NEGATOR = <=
);

CREATE OPERATOR > (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_gt,
   NEGATOR = <=
);

--
-- btree-joins.  (hash joins require a hashcode function.)
--
CREATE OPERATOR CLASS bignum_ops
   DEFAULT FOR TYPE bignum USING btree AS
      OPERATOR  1  <,
      OPERATOR  2  <=,
      OPERATOR  3  =,
      OPERATOR  4  >=,
      OPERATOR  5  >,
      FUNCTION  1 bn_cmp(bignum, bignum);
 
--
-- Mathematical operations
--
CREATE OR REPLACE FUNCTION bn_negate(bignum) RETURNS bignum
AS 'bignum', 'pgx_bignum_negate'
LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR - (
   RIGHTARG = bignum,
   PROCEDURE = bn_negate
);

CREATE OR REPLACE FUNCTION bn_add(bignum, bignum) RETURNS bignum
AS 'bignum', 'pgx_bignum_add'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_add_i8(bignum, int8) RETURNS bignum
AS 'bignum', 'pgx_bignum_add_i8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_add_i8(int8, bignum) RETURNS bignum AS $$
   SELECT bn_add_i8($2, $1);
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_subtract(bignum, bignum) RETURNS bignum
AS 'bignum', 'pgx_bignum_subtract'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_subtract_i8(bignum, int8) RETURNS bignum
AS 'bignum', 'pgx_bignum_subtract_i8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_subtract_i8(int8, bignum) RETURNS bignum AS $$
   SELECT -bn_subtract_i8($2, $1);
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_multiply(bignum, bignum) RETURNS bignum
AS 'bignum', 'pgx_bignum_multiply'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_multiply_i8(bignum, int8) RETURNS bignum
AS 'bignum', 'pgx_bignum_multiply_i8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_multiply_i8(int8, bignum) RETURNS bignum AS $$
   SELECT bn_multiply_i8($2, $1);
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_divide(bignum, bignum) RETURNS bignum
AS 'bignum', 'pgx_bignum_divide'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_divide_i8(bignum, int8) RETURNS bignum
AS 'bignum', 'pgx_bignum_divide_bi8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_divide_i8(int8, bignum) RETURNS bignum
AS 'bignum', 'pgx_bignum_divide_i8b'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_modulus(bignum, bignum) RETURNS bignum
AS 'bignum', 'pgx_bignum_modulus'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_modulus_i8(bignum, int8) RETURNS bignum
AS 'bignum', 'pgx_bignum_modulus_bi8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_modulus_i8(int8, bignum) RETURNS bignum
AS 'bignum', 'pgx_bignum_modulus_i8b'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_gcd(bignum, bignum) RETURNS bignum
AS 'bignum', 'pgx_bignum_gcd'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_gcd_i8(bignum, int8) RETURNS bignum
AS 'bignum', 'pgx_bignum_gcd_i8'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_gcd_i8(int8, bignum) RETURNS bignum AS $$
   SELECT bn_gcd_i8($2, $1);
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION bn_gcd_ii(int8, int8) RETURNS bignum
AS 'bignum', 'pgx_bignum_gcd_ii'
LANGUAGE C IMMUTABLE STRICT;

CREATE OPERATOR + (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_add,
   COMMUTATOR = +
);

CREATE OPERATOR + (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_add_i8,
   COMMUTATOR = +
);

CREATE OPERATOR + (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_add_i8,
   COMMUTATOR = +
);

CREATE OPERATOR - (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_subtract
);

CREATE OPERATOR - (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_subtract_i8
);

CREATE OPERATOR - (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_subtract_i8
);

CREATE OPERATOR * (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_multiply,
   COMMUTATOR = *
);

CREATE OPERATOR * (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_multiply_i8,
   COMMUTATOR = *
);

CREATE OPERATOR * (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_multiply_i8,
   COMMUTATOR = *
);

CREATE OPERATOR / (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_divide
);

CREATE OPERATOR / (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_divide_i8
);

CREATE OPERATOR / (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_divide_i8
);

CREATE OPERATOR % (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_modulus
);

CREATE OPERATOR % (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_modulus_i8
);

CREATE OPERATOR % (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_modulus_i8
);

CREATE OPERATOR | (
   LEFTARG = bignum,
   RIGHTARG = bignum,
   PROCEDURE = bn_gcd
);

CREATE OPERATOR | (
   LEFTARG = bignum,
   RIGHTARG = int8,
   PROCEDURE = bn_gcd_i8
);

CREATE OPERATOR | (
   LEFTARG = int8,
   RIGHTARG = bignum,
   PROCEDURE = bn_gcd_i8
);

CREATE OPERATOR | (
   LEFTARG = int8,
   RIGHTARG = int8,
   PROCEDURE = bn_gcd_ii
);

CREATE OR REPLACE FUNCTION bn_abs(bignum) RETURNS bool
AS 'bignum', 'pgx_bignum_abs'
LANGUAGE C IMMUTABLE STRICT;

--
-- primes...
--
--CREATE FUNCTION bn_gen_prime(int, int) RETURNS BIGNUM
--AS 'bignum', 'pgx_bignum_gen_prime'
--LANGUAGE C IMMUTABLE STRICT;

--CREATE FUNCTION bn_is_prime(bignum, int) RETURNS bool
--AS 'bignum', 'pgx_bignum_is_prime'
--LANGUAGE C IMMUTABLE STRICT;
