-- Driver psql de la migracion fundacional v0.2
\set ON_ERROR_STOP on
\ir 000_01_schema.sql
\ir 000_02_logic.sql
\ir 000_03_seed.sql
