# To generate DBIX Schema lib files for warehouse DB
use DBIx::Class::Schema::Loader qw/ make_schema_at /;
make_schema_at(
    'Schema',
    { debug => 1,
      dump_directory => './lib',
    },
    [ 'dbi:SQLite:dbname=warehouse.db', '', '',
    ],
);