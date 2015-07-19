bignum
======

Synopsis
--------

'bignum' is a user-defined type that implements unlimited precision integers.

Description
-----------

'bignum' is a user-defined type that implements unlimited-precision integers using the
OpenSSL library. All of the standard arithmetic, equality, and comparison operations are
defined as expected.

The greatest common demoninator (GCD) function is supported.

The aggregate functions (min, max, sum, avg) are not supported at this time.

Casts to/from DECIMAL, NUMERIC, and existing multiple-precision integer extensions
are not supported at this time.

Usage
-----

Install the extension in the usual manner.

```sql
CREATE EXTENSION bignum;
```

The bignum can now be used as a standard type.

```sql
CREATE TABLE test (
   a    INT,
   b    BIGNUM
);

INSERT INTO table(a, b) VALUES (1, '1');
INSERT INTO table(a, b) VALUES (2, 2);
INSERT INTO table(a, b) VALUES (3, 3::int8);
```

We can now do standard math on the type. Note that int4 and int8 values are
automatically cast to bignum values so we don't have to do it manually.


```sql
bgiles=# create table t (a int, b bignum, c bignum);
CREATE TABLE
bgiles=# insert into t values (1, 1, 2), (2, 3, 4), (3, -2, -3);
INSERT 0 3

-- comparisons
bgiles=# select a, b, c, b < c as d, b <= c as d, b = c as f, b >= c as g, b > c as h, b <> c as i from t;
 a | b  | c  | d | d | f | g | h | i 
---+----+----+---+---+---+---+---+---
 1 | 1  | 2  | t | t | f | f | f | t
 2 | 3  | 4  | t | t | f | f | f | t
 3 | -2 | -3 | f | f | f | t | t | t
(3 rows)

-- negation and absolute values.
bgiles=# select a, b, c, -b as d, abs(c) as e from t;
 a | b  | c  | d  | e 
---+----+----+----+---
 1 | 1  | 2  | -1 | 2
 2 | 3  | 4  | -3 | 4
 3 | -2 | -3 | 2  | 3
(3 rows)

-- basic math
bgiles=# select a, b, c, b+c as d, b-c as e, b*c as f, b/c as g, b%c as h from t;
 a | b  | c  | d  | e  | f  | g | h  
---+----+----+----+----+----+---+----
 1 | 1  | 2  | 3  | -1 | 2  | 0 | 1
 2 | 3  | 4  | 7  | -1 | 12 | 0 | 3
 3 | -2 | -3 | -5 | 1  | 6  | 0 | -2
(3 rows)

-- Greatest common denominator.
bgiles=# select gcd(3::bignum, 12::bignum) as a, gcd(5::bignum, 12::bignum) as b;
 a | b 
---+---
 3 | 1
(1 row)

```

Support
-------

Source code is available at https://github.com/beargiles/pg-bignum.

Write me if you need additional functionality. There's a good chance that I've already
started work on it but have deferred publication until I identify a need and resolve
a few open questions.

Author
------

Bear Giles <bgiles@coyotesong.com>

Copyright and License
---------------------

Copyright (c) 2015 Bear Giles <bgiles@coyotesong.com>

