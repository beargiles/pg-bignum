\set ECHO none
BEGIN;
\i sql/bignum.sql
\set ECHO all

SELECT bignum('0'), bignum('1'), bignum('-1');

SELECT 0::bignum, 1::bignum, (-1)::bignum;

SELECT (1::int8)::bignum, (-1::int8)::bignum;

ROLLBACK;
