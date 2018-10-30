package WarehouseAPI::WarehouseObj;

use Modern::Perl '2013';
use Moose;

use Schema;

has 'warehouse_id' => (
    is  => 'ro',
    isa => 'Int',
    writer => '_set_warehouse_id',
);

has 'warehouse_name' => (
    is  => 'ro',
    isa => 'Str',
    writer => '_set_warehouse_name',
);

has 'schema' => (
    is  => 'ro',
    isa => 'Schema',
    default => sub { Schema->connect('dbi:SQLite:warehouse.db') },
);


sub BUILD {
    my $self = shift;
    my $schema = $self->schema;
    my $warehouse_id = $self->warehouse_id;
    my $warehouse_name = $self->warehouse_name;

    # When both warehouse_id and name are provided, make sure it is a match
    if ($warehouse_id && $warehouse_name) {
        my $warehouse_db = $schema->resultset('Warehouse')->find($warehouse_id);
        unless  ($warehouse_db->name eq $warehouse_name) {
            die "ERROR: Warehouse name '$warehouse_name' is not associated with ID $warehouse_id";
        }
    # If warehouse_name is provided, search for id if available
    } elsif ($warehouse_name) {
        my $existing_warehouse = $schema->resultset('Warehouse')->search({name => $warehouse_name})->first;
        $self->_set_warehouse_id($existing_warehouse->id) if $existing_warehouse;
    # If warehouse_id is provided, search for warehouse by id
    } elsif ($warehouse_id) {
        my $existing_warehouse = $schema->resultset('Warehouse')->find($warehouse_id)
            || die "ERROR: Cannot find warehouse by ID $warehouse_id!";
        $self->_set_warehouse_name($existing_warehouse->name);
    }
}

# Method to create warehouse db record
# Required: Warehouse name
sub create_warehouse {
    my $self = shift;
    my $schema = $self->schema;
    my $warehouse_name = $self->warehouse_name;
    if ($self->warehouse_id) {
        die "ERROR: warehouse_name $warehouse_name is existing with id " . $self->warehouse_id;
    }
    my $warehouse_db = $schema->resultset('Warehouse')->create({name => $warehouse_name}) ||
        die "ERROR: Cannot create warehouse with name $warehouse_name";

    $self->_set_warehouse_id($warehouse_db->id);
    return;
}


1;