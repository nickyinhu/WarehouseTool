package WarehouseAPI;

use Modern::Perl '2013';
use Moose;
use JSON;

use Schema;
use WarehouseAPI::WarehouseObj;
use WarehouseAPI::InventoryObj;
use WarehouseAPI::OrderObj;
use WarehouseAPI::ItemObj;

has 'warehouse_id' => (
    is  => 'rw',
    isa => 'Int',
);

has 'warehouse_name' => (
    is  => 'rw',
    isa => 'Str',
);

has 'order_id' => (
    is  => 'ro',
    isa => 'Int',
    writer => '_set_order_id',
);

has 'upc' => (
    is  => 'rw',
    isa => 'Str',
);

has 'quantity' => (
    is  => 'rw',
    isa => 'Int',
);

has 'price' => (
    is  => 'rw',
    isa => 'Int',
);


# Create a new warehouse
sub new_warehouse {
    my $self = shift;
    my $warehouse_name = $self->warehouse_name;
    die "ERROR: Warehouse_name is needed to create a new warehouse!" unless defined $warehouse_name;
    my $warehouse_obj = WarehouseAPI::WarehouseObj->new(warehouse_name => $warehouse_name);
    $warehouse_obj->create_warehouse;

    return $self->_get_json({warehouse_id => $warehouse_obj->warehouse_id, name => $warehouse_obj->warehouse_name});
}

# Add item to inventory of a warehouse
sub add_inventory {
    my $self = shift;
    die "ERROR: Item quantity is needed to add item to inventory!" unless defined $self->quantity;
    die "ERROR: Warehouse_name is needed to add item to inventory!" unless defined $self->warehouse_name;
    die "ERROR: Quantity is needed to add item to inventory!" unless defined $self->quantity;
    die "ERROR: UPC is needed to add item to inventory!" unless defined $self->upc;

    my $inventory_obj = WarehouseAPI::InventoryObj->new(
        upc            => $self->upc,
        quantity       => $self->quantity,
        warehouse_name => $self->warehouse_name,
        price          => $self->price,
    );
    my $result = $inventory_obj->add_inventory();

    return $self->_get_json($result);
}

# Check quantity of item in a warehouse's inventory
sub check_available {
    my $self = shift;
    die "ERROR: Warehouse_name is needed to check availability!" unless defined $self->warehouse_name;
    die "ERROR: UPC is needed to check availability!" unless defined $self->upc;

    my $inventory_obj = WarehouseAPI::InventoryObj->new(
        upc            => $self->upc,
        warehouse_name => $self->warehouse_name,
    );
    my $result = $inventory_obj->check_available_item();

    return $self->_get_json($result);
}

# Create an order from a warehouse
sub place_order {
    my $self = shift;
    die "ERROR: Warehouse_name is needed to place an order!" unless defined $self->warehouse_name;
    die "ERROR: Quantity is needed to place an order!" unless defined $self->quantity;
    die "ERROR: UPC is needed to place an order!" unless defined $self->upc;

    my $order_obj = WarehouseAPI::OrderObj->new(
        upc            => $self->upc,
        quantity       => $self->quantity,
        warehouse_name => $self->warehouse_name,
    );
    my $result = $order_obj->create_order();

    return $self->_get_json($result);
}


sub add_order_item {
    my $self = shift;
    die "ERROR: Order_id is needed to update an order!" unless defined $self->order_id;
    die "ERROR: Quantity is needed to update an order!" unless defined $self->quantity;
    die "ERROR: UPC is needed to update an order!" unless defined $self->upc;

    my $order_obj = WarehouseAPI::OrderObj->new(
        upc      => $self->upc,
        quantity => $self->quantity,
        order_id => $self->order_id,
    );
    my $result = $order_obj->add_item_to_order();

    return $self->_get_json($result);
}


# Check order detail
sub check_order {
    my $self = shift;
    die "ERROR: Order_id is needed to check an order!" unless defined $self->order_id;

    my $order_obj = WarehouseAPI::OrderObj->new(order_id => $self->order_id);
    my $result = $order_obj->check_order_detail();

    return $self->_get_json($result);
}

# Cancel an order
sub cancel_order {
    my $self = shift;
    die "ERROR: Order_id is needed to Cancel an order!" unless defined $self->order_id;

    my $order_obj = WarehouseAPI::OrderObj->new(order_id => $self->order_id);
    my $result = $order_obj->cancel_order();

    return $self->_get_json($result);
}


# Ship an order
sub ship_order {
    my $self = shift;
    die "ERROR: Order_id is needed to ship an order!" unless defined $self->order_id;

    my $order_obj = WarehouseAPI::OrderObj->new(order_id => $self->order_id);
    my $result = $order_obj->ship_order();

    return $self->_get_json($result);
}



# Helper method to convert hashref to JSON
sub _get_json {
    my $self = shift;
    my $result_hash = shift;
    die unless $result_hash && ref $result_hash && ref $result_hash eq 'HASH';
    my $json = encode_json $result_hash;
    return "Success! Result:\n$json";
}




1;