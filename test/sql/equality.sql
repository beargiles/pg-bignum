\set ECHO none
BEGIN;
\i sql/bignum.sql
\set ECHO all

\set d0 0::bignum
\set d1 1::bignum
\set n1 -1::bignum

SELECT :d0;

SELECT :d1;

SELECT :n1;

SELECT :d0 AS a, :d1 AS b, :n1 AS c;

SELECT :d0 < :d0 AS a, :d0 <= :d0 AS b, :d0 = :d0 as c, :d0 >= :d0 as d, :d0 > :d0 as e, :d0 <> :d0 as f;

SELECT :d0 < 0 AS a, :d0 <= 0 AS b, :d0 = 0 as c, :d0 >= 0 as d, :d0 > 0 as e, :d0 <> 0 as f;

SELECT :d0 < :d1 AS a, :d0 <= :d1 AS b, :d0 = :d1 as c, :d0 >= :d1 as d, :d0 > :d1 as e, :d0 <> :d1 as f;

SELECT :d0 < 1 AS a, :d0 <= 1 AS b, :d0 = 1 as c, :d0 >= 1 as d, :d0 > 1 as e, :d0 <> 1 as f;

SELECT :n1 < :d1 AS a, :n1 <= :d1 AS b, :n1 = :d1 as c, :n1 >= :d1 as d, :n1 > :d1 as e, :n1 <> :d1 as f;

SELECT -1, :d1;

SELECT -1 < :d1 AS a, -1 <= :d1 AS b, -1 = :d1 as c, -1 >= :d1 as d, -1 > :d1 as e, -1 <> :d1 as f;

ROLLBACK;
