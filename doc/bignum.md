bignum
======

Synopsis
--------

'bignum' is a user-defined type that implements unlimited precision integers

Description
-----------

'bignum' is a user-defined type that implements unlimited-precision integers using the
OpenSSL library.

Usage
-----

You can create a bignum by casting an int4 or int8 value to this type. It is not
currently possible to cast from a bignum to an int4 or int8 value due to the risk of
overflow.

All of the standard arithmetic, equality, and comparison operations are defined as
expected.

(TBD: gcd, etc.)


Support
-------

Source code is available at https://github.com/beargiles/pg-bignum.

Author
------

Bear Giles <bgiles@coyotesong.com>

Copyright and License
---------------------

Copyright (c) 2015 Bear Giles <bgiles@coyotesong.com>

