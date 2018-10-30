package WarehouseAPI::ItemObj;

use Modern::Perl '2013';
use Moose;

use Schema;

has 'item_id' => (
    is  => 'ro',
    isa => 'Int',
    writer => '_set_item_id',
);

has 'upc' => (
    is  => 'ro',
    isa => 'Str',
    writer => '_set_upc',
);

has 'price' => (
    is  => 'ro',
    isa => 'Str|Undef',
    writer => '_set_price',
);

has 'schema' => (
    is  => 'ro',
    isa => 'Schema',
    default => sub { Schema->connect('dbi:SQLite:warehouse.db') },
);


sub BUILD {
    my $self = shift;
    my $schema = $self->schema;
    my $item_id = $self->item_id;
    my $item_upc = $self->upc;

    # When item_upc and item_id are provided, make sure it is a match
    if ($item_upc && $item_id) {
        my $item_db = $schema->resultset('Item')->find($item_id);
        unless  ($item_db->upc eq $item_upc) {
            die "ERROR: Item UPC '$item_upc' is not associated with ID $item_id";
        }
        $self->_set_upc($item_db->price);
    # If item_upc is provided, search for id if available
    } elsif ($item_upc) {
        my $existing_item = $schema->resultset('Item')->search({upc => $item_upc})->first;
        if ($existing_item) {
            $self->_set_item_id($existing_item->id);
            $self->_set_price($existing_item->price);
        }
    # If item_id is provided, search for Item by id
    } elsif ($item_id) {
        my $item_db = $schema->resultset('Item')->find($item_id)
            || die "ERROR: Cannot find Item by ID $item_id!";
        $self->_set_upc($item_db->upc);
        $self->_set_price($item_db->price);
    }
}

# Method to create item db record
# Required: UPC
sub create_item {
    my $self = shift;
    my $schema = $self->schema;
    my $item_upc = $self->upc;
    if ($self->item_id) {
        die "ERROR: UPC $item_upc is existing with id " . $self->item_id;
    }
    if (!defined $self->price) {
        die "ERROR: Price is required to add a new item";
    }
    my $item_db = $schema->resultset('Item')->create({upc => $item_upc, price => $self->price}) ||
        die "ERROR: Cannot create item with UPC $item_upc";

    $self->_set_item_id($item_db->id);
    return;
}


1;