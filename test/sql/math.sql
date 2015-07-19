\set ECHO none
BEGIN;
\i sql/bignum.sql
\set ECHO all

\set d0 0::bignum
\set d1 1::bignum
\set d2 2::bignum
\set n1 -1::bignum
\set n2 -2::bignum

--
-- test addition
--
SELECT :d0 + :d0 as a, :d0 + 0 as b, 0 + :d0 as c;
SELECT :d1 + :d1 as a, :d1 + 1 as b, 1 + :d1 as c;
SELECT :d1 + :d2 as a, :d1 + 2 as b, 1 + :d2 as c;
SELECT :d1 + :n1 as a, :d1 + -1 as b, 1 + :n1 as c;
SELECT :d1 + :n2 as a, :d1 + -2 as b, 1 + :n2 as c;

--
-- test subtraction
--
SELECT :d0 - :d0 as a, :d0 - 0 as b, 0 - :d0 as c;
SELECT :d1 - :d1 as a, :d1 - 1 as b, 1 - :d1 as c;
SELECT :d1 - :d2 as a, :d1 - 2 as b, 1 - :d2 as c;
SELECT :d1 - :n1 as a, :d1 - -1 as b, 1 - :n1 as c;
SELECT :d1 - :n2 as a, :d1 - -2 as b, 1 - :n2 as c;

--
-- test multiplication
--
SELECT :d0 * :d0 as a, :d0 * 0 as b, 0 * :d0 as c;
SELECT :d1 * :d1 as a, :d1 * 1 as b, 1 * :d1 as c;
SELECT :d1 * :d2 as a, :d1 * 2 as b, 1 * :d2 as c;
SELECT :d1 * :n1 as a, :d1 * -1 as b, 1 * :n1 as c;
SELECT :d1 * :n2 as a, :d1 * -2 as b, 1 * :n2 as c;

--
-- test division
--
SELECT :d0 / :d0 as a, :d0 / 0 as b, 0 / :d0 as c;
SELECT :d1 / :d1 as a, :d1 / 1 as b, 1 / :d1 as c;
SELECT :d1 / :d2 as a, :d1 / 2 as b, 1 / :d2 as c;
SELECT :d2 / :d1 as a, :d2 / 1 as b, 2 / :d1 as c;
SELECT :d1 / :n1 as a, :d1 / -1 as b, 1 / :n1 as c;
SELECT :d1 / :n2 as a, :d1 / -2 as b, 1 / :n2 as c;

--
-- test modulus
--
SELECT :d0 % :d0 as a, :d0 / 0 as b, 0 / :d0 as c;
SELECT :d0 % :d1 as a, :d0 % 1 as b, 0 % :d1 as c;
SELECT :d1 % :d1 as a, :d1 % 1 as b, 1 % :d1 as c;
SELECT :d1 % :d2 as a, :d1 % 2 as b, 1 % :d2 as c;
SELECT :d2 % :d1 as a, :d2 % 1 as b, 2 % :d1 as c;
SELECT :d1 % :n1 as a, :d1 % -1 as b, 1 % :n1 as c;
SELECT :d1 % :n2 as a, :d1 % -2 as b, 1 % :n2 as c;

--
-- test GCD
--
SELECT gcd(3::bignum, 12::bignum) as a, gcd(5::bignum, 12::bignum) as b;
SELECT gcd(3::bignum, 12) as a, gcd(5::bignum, 12) as b;
SELECT gcd(3, 12::bignum) as a, gcd(5, 12::bignum) as b;

ROLLBACK;
