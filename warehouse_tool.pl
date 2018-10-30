use Modern::Perl '2013';
use Getopt::Long;
use JSON;
use DDP;

use WarehouseAPI;

GetOptions (
    "option=s"            => \my $option,
    "order_id=i"          => \my $order_id,
    "upc=s"               => \my $upc,
    "quantity=i"          => \my $quantity,
    "price=i"             => \my $price,
    "warehouse_name=s"    => \my $warehouse_name,
    "help"                => \my $help,
);

my $function = {
    new_warehouse   => \&new_warehouse,
    add_inventory   => \&add_inventory,
    check_available => \&check_available,
    place_order     => \&place_order,
    add_order_item  => \&add_order_item,
    ship_order      => \&ship_order,
    check_order     => \&check_order,
    cancel_order    => \&cancel_order,
};

usage() if ($help || !$option || !exists $function->{$option});
# Create API
my $warehouse_api = WarehouseAPI->new(_generate_args());

# Execute user's option
$function->{$option}->();

# To create a new warehouse with provided name
sub new_warehouse {
    my $result = $warehouse_api->new_warehouse();
    say $result;
}
# Add item into inventory
sub add_inventory {
    my $result = $warehouse_api->add_inventory();
    say $result;
}
# Check available inventory for an item
sub check_available {
    my $result = $warehouse_api->check_available();
    say $result;
}
# Create an order with item
sub place_order {
    my $result = $warehouse_api->place_order();
    say $result;
}
# Add more item into an open order
sub add_order_item {
    my $result = $warehouse_api->add_order_item();
    say $result;
}
# Check an order
sub check_order {
    my $result = $warehouse_api->check_order();
    say $result;
}
# Ship an order
sub ship_order {
    my $result = $warehouse_api->ship_order();
    say $result;
}
# Cancel an order
sub cancel_order {
    my $result = $warehouse_api->cancel_order();
    say $result;
}


sub _generate_args {
    my $args = {};
    $args->{order_id} = $order_id if $order_id;
    $args->{upc}      = $upc      if $upc;
    $args->{price}    = $price    if $price;
    $args->{quantity} = $quantity if $quantity;
    $args->{warehouse_name} = $warehouse_name if $warehouse_name;

    return $args;
}


sub usage {
    say "HELP! Please read README.txt for usage";
    exit;
}