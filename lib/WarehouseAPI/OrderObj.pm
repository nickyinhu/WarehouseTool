package WarehouseAPI::OrderObj;

use Modern::Perl '2013';
use Moose;

use Schema;
use WarehouseAPI::OrderItemObj;

has 'order_id' => (
    is  => 'ro',
    isa => 'Int',
    writer => '_set_order_id',
);

has 'warehouse_obj' => (
    is  => 'rw',
    isa => 'WarehouseAPI::WarehouseObj',
);

has 'order_detail' => (
    is => 'rw',
    isa => 'ArrayRef[WarehouseAPI::OrderItemObj]',
    default => sub { [] },
    lazy    => 1,
    clearer => '_clear_detail',
);

has 'schema' => (
    is  => 'ro',
    isa => 'Schema',
    default => sub { Schema->connect('dbi:SQLite:warehouse.db') },
);


sub BUILD {
    my $self = shift;
    my $args = shift;
    my $schema = $self->schema;
    my $order_id = $self->order_id;

    # When order_id is provided, try to verify
    if ($order_id) {
        my $order_db = $schema->resultset('WarehouseOrder')->find($order_id);
        die "ERROR: Cannot find order by id $order_id!" unless $order_db;
        my $warehouse_obj = WarehouseAPI::WarehouseObj->new(warehouse_id => $order_db->warehouse_id);
        $self->warehouse_obj($warehouse_obj);
    }

    if (defined $args->{warehouse_name}) {
        my $warehouse_obj = WarehouseAPI::WarehouseObj->new(warehouse_name => $args->{warehouse_name});
        $self->warehouse_obj($warehouse_obj);
    }
    if (defined $args->{upc} && defined $args->{quantity}) {
        my $item_obj = WarehouseAPI::ItemObj->new(upc => $args->{upc});
        die "ERROR: Cannot find item by UPC $args->{upc}!" unless $item_obj->item_id;
        my $order_item_obj = WarehouseAPI::OrderItemObj->new(item_obj=> $item_obj, quantity => $args->{quantity});
        push @{$self->order_detail}, $order_item_obj;
    }
}

# Method to create an order
# Required: Warehouse, UPC, Quantity
# Return: Order detail
sub create_order {
    my $self = shift;
    my $schema = $self->schema;
    my $warehouse_obj = $self->warehouse_obj || die "ERROR: Must provide warehouse name to place an order";
    my $warehouse_id  = $warehouse_obj->warehouse_id ||
        die "ERROR: Warehouse ". $warehouse_obj->warehouse_name . " is not existing!";

    my $order_item_obj = $self->order_detail->[0] || die "UPC and quantity are Required to place an order";
    my $item = $order_item_obj->item_obj;

    # Check if we have enough inventory
    my $item_inventory = $self->check_inventory_availability($item->item_id, $order_item_obj->quantity);

    #
    # Order creation
    #
    # Calculate order subtotal, create order record
    my $order_total = $item->price * $order_item_obj->quantity;

    my $order = $schema->resultset('WarehouseOrder')->create({warehouse_id => $warehouse_id, order_total => $order_total});
    my $order_id = $order->id;
    $order = $schema->resultset('WarehouseOrder')->find($order_id);
    $self->_set_order_id($order_id);

    # Create related order detail
    $order->create_related('order_details',{item_id => $item->item_id, quantity => $order_item_obj->quantity});

    #
    # After order is created, update inventory
    #
    $item_inventory->update({
        available_quantity => $item_inventory->available_quantity - $order_item_obj->quantity,
        reserved_quantity => $item_inventory->reserved_quantity + $order_item_obj->quantity,
    });

    my $result = $self->check_order_detail();

    return $result;
}

# Method to add item to an order
# Required: Order ID, UPC, quantity
# Return: Order detail
sub add_item_to_order {
    my $self = shift;
    die "Order ID is Required to add more item to an order" unless $self->order_id;
    my $schema = $self->schema;

    my $order = $schema->resultset('WarehouseOrder')->find($self->order_id);
    die "ERROR: Order has been shipped, cannot add item to order!" if $order->order_status eq 'shipped';
    die "ERROR: Order has already been canceled, cannot add item to order!" if $order->order_status eq 'canceled';

    my $order_item_obj = $self->order_detail->[0] || die "UPC and quantity are Required to place an order";
    my $item = $order_item_obj->item_obj;

    # Check if we have enough inventory
    my $item_inventory = $self->check_inventory_availability($item->item_id, $order_item_obj->quantity);

    $item_inventory->update({
        available_quantity => $item_inventory->available_quantity - $order_item_obj->quantity,
        reserved_quantity => $item_inventory->reserved_quantity + $order_item_obj->quantity,
    });

    $order->create_related('order_details',{item_id => $item->item_id, quantity => $order_item_obj->quantity});
    my $order_total = $item->price * $order_item_obj->quantity;
    $order->update({order_total => $order->order_total + $order_total});

    my $result = $self->check_order_detail();

    return $result;
}

# Method to check an order
# Required: Order ID
# Return: Order detail
sub check_order_detail {
    my $self = shift;
    die "Order ID is Required to check order status" unless $self->order_id;
    my $schema = $self->schema;
    my $warehouse_obj = $self->warehouse_obj;

    my $order = $schema->resultset('WarehouseOrder')->find($self->order_id);

    my @order_details = $order->order_details;
    $self->build_order_detail(\@order_details);

    my $result = {
        order_id  => $self->order_id,
        sub_total => '$' . $order->order_total,
        warehouse => $warehouse_obj->warehouse_name,
        order_status => $order->order_status,
        order_detail => [],
    };

    for my $order_item (@{$self->order_detail}) {
        my $order_detail = {
            UPC      => $order_item->item_obj->upc,
            quantity => $order_item->quantity,
            price    => '$' . $order_item->item_obj->price,
        };
        push @{$result->{order_detail}}, $order_detail;
    }

    return $result;
}


# Method to cancel an order
# Required: Order ID
# Return: Order detail
sub cancel_order {
    my $self = shift;
    die "Order ID is Required to cancel an order" unless $self->order_id;
    my $order_id = $self->order_id;
    my $schema = $self->schema;
    my $warehouse_obj = $self->warehouse_obj;

    my $order = $schema->resultset('WarehouseOrder')->find($self->order_id);
    die "ERROR: Order $order_id has been shipped, cannot cancel!" if $order->order_status eq 'shipped';
    die "ERROR: Order $order_id is already in canceled status!" if $order->order_status eq 'canceled';

    my @order_details = $order->order_details;
    $self->build_order_detail(\@order_details);

    # Reset inventory for items in this order
    for my $order_item (@{$self->order_detail}) {
        my $item_id = $order_item->item_obj->item_id;
        my $quantity = $order_item->quantity;
        my $inventory_db = $schema->resultset('Inventory')->search({
            item_id      => $item_id,
            warehouse_id => $warehouse_obj->warehouse_id,
        })->first;
        $inventory_db->update({
            available_quantity => $inventory_db->available_quantity + $quantity,
            reserved_quantity  => $inventory_db->reserved_quantity - $quantity,
        });
    }

    $order->update({order_status => 'canceled'});

    my $result = $self->check_order_detail();

    return $result;
}


# Method to ship an order
# Required: Order ID
# Return: Order detail
sub ship_order {
    my $self = shift;
    die "Order ID is Required to ship an order" unless $self->order_id;
    my $order_id = $self->order_id;
    my $schema = $self->schema;
    my $warehouse_obj = $self->warehouse_obj;

    my $order = $schema->resultset('WarehouseOrder')->find($self->order_id);
    die "ERROR: Order $order_id has already been shipped!" if $order->order_status eq 'shipped';
    die "ERROR: Order $order_id is in canceled status, cannot ship!" if $order->order_status eq 'canceled';

    my @order_details = $order->order_details;
    $self->build_order_detail(\@order_details);

    # Remove reserved from inventory
    for my $order_item (@{$self->order_detail}) {
        my $item_id = $order_item->item_obj->item_id;
        my $quantity = $order_item->quantity;
        my $inventory_db = $schema->resultset('Inventory')->search({
            item_id      => $item_id,
            warehouse_id => $warehouse_obj->warehouse_id,
        })->first;
        $inventory_db->update({reserved_quantity => $inventory_db->reserved_quantity - $quantity});
    }

    $order->update({order_status => 'shipped'});

    my $result = $self->check_order_detail();

    return $result;
}

# Helper function to Check availability of an item
sub check_inventory_availability {
    my $self     = shift;
    my $item_id  = shift;
    my $quantity = shift;
    my $schema   = $self->schema;

    my $item_inventory = $schema->resultset('Inventory')->search({
        warehouse_id => $self->warehouse_obj->warehouse_id,
        item_id      => $item_id
    })->first || die "ERROR: Cannot find Inventory for Warehouse " . $self->warehouse_obj->warehouse_name;
    my $available = $item_inventory->available_quantity;
    die "ERROR: Cannot locate enough inventory for this item, only $available is available" if $available < $quantity;
    return $item_inventory;
}

# Helper function to build order_detail structure
sub build_order_detail {
    my $self = shift;
    my $order_details = shift;
    $self->_clear_detail;
    for my $single_item (@{$order_details}) {
        my $item_obj = WarehouseAPI::ItemObj->new(item_id => $single_item->item_id);
        my $order_item_obj = WarehouseAPI::OrderItemObj->new(item_obj=> $item_obj, quantity => $single_item->quantity);
        push @{$self->order_detail}, $order_item_obj;
    }
}


1;