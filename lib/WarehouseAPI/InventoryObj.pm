package WarehouseAPI::InventoryObj;

use Modern::Perl '2013';
use Moose;

use Schema;

has 'upc' => (
    is  => 'ro',
    isa => 'Str',
);

has 'quantity' => (
    is  => 'ro',
    isa => 'Int',
);

has 'warehouse_obj' => (
    is  => 'rw',
    isa => 'WarehouseAPI::WarehouseObj',
);

has 'item_obj' => (
    is  => 'rw',
    isa => 'WarehouseAPI::ItemObj',
);


has 'schema' => (
    is  => 'ro',
    isa => 'Schema',
    default => sub { Schema->connect('dbi:SQLite:warehouse.db') },
);


sub BUILD {
    my $self = shift;
    my $args = shift;
    my $warehouse_name = $args->{warehouse_name};
    die "Warehouse name is required for inventory option!" unless defined $warehouse_name;
    my $upc = $args->{upc};
    die "Item UPC is required for inventory option!" unless defined $upc;

    my $warehouse_obj = WarehouseAPI::WarehouseObj->new(warehouse_name => $args->{warehouse_name});
    my $warehouse_id   = $warehouse_obj->warehouse_id || die "Warehouse ". $warehouse_obj->warehouse_name . " is not existing!";
    $self->warehouse_obj($warehouse_obj);


    my $item_obj = WarehouseAPI::ItemObj->new(upc => $upc, price => $args->{price});
    $self->item_obj($item_obj);
}

# Method to add item to inventory, create item record if not existing
# Return: total_available after adding to inventory, and other provided information
sub add_inventory {
    my $self = shift;
    my $schema         = $self->schema;
    my $warehouse_obj  = $self->warehouse_obj;
    my $item_obj       = $self->item_obj;
    my $quantity       = $self->quantity;

    # Create item in DB if this is new item
    if (!$item_obj->item_id) {
        $item_obj->create_item();
    }
    my $item_id    = $item_obj->item_id;
    my $item_price = $item_obj->price;

    # Check if there is an entry for such item in the warehouse's inventory already, if so, update quantity, else, create inventory
    my $inventory_db = $schema->resultset('Inventory')->find_or_create({
        warehouse_id => $warehouse_obj->warehouse_id,
        item_id => $item_id
    });
    $inventory_db = $schema->resultset('Inventory')->find($inventory_db->id);
    # Add new quantity to available quantity and update DB
    my $new_quantity = $inventory_db->available_quantity + $quantity;
    $inventory_db->update({available_quantity => $new_quantity});

    my $result = {
        UPC             => $item_obj->upc,
        warehouse_name  => $warehouse_obj->warehouse_name,
        price           => '$' . $item_obj->price,
        added_quantity  => $quantity,
        total_available => $inventory_db->available_quantity,
        total_reserved  => $inventory_db->reserved_quantity,
    };
    return $result;
}


# Method to check item to inventory
# Required: warehouse_name, UPC
# Return: available_quantity, reserved_quantity,  and other provided information
sub check_available_item {
    my $self = shift;
    my $schema = $self->schema;
    my $warehouse_obj = $self->warehouse_obj;
    my $item_obj      = $self->item_obj;
    my $item_upc      = $item_obj->upc;

    die "Item is not existing (UPC: $item_upc)" unless $item_obj->item_id; # Item is not existing
    my $result = {
        UPC                => $item_upc,
        warehouse_name     => $warehouse_obj->warehouse_name,
        available_quantity => 0,
        reserved_quantity  => 0,
        price              => '$' . $item_obj->price,
    };

    my $inventory_db = $schema->resultset('Inventory')->search({
        warehouse_id => $warehouse_obj->warehouse_id,
        item_id => $item_obj->item_id
    })->first;

    if ($inventory_db) {
        $result->{available_quantity} = $inventory_db->available_quantity;
        $result->{reserved_quantity}  = $inventory_db->reserved_quantity;
    }

    return $result;
}

1;