--
-- This file is released under the PostgreSQL license by its author,
-- Bear Giles <bgiles@coyotesong.com>
--
-- -------------------------------------------------------------------------------

--
-- Drop the user-defined types. Note: this will also nuke any user tables that include
-- this type.
--
DROP TYPE bignum CASCADE;
