package WarehouseAPI::OrderItemObj;

use Modern::Perl '2013';
use Moose;

has 'item_obj' => (
    is  => 'rw',
    isa => 'WarehouseAPI::ItemObj',
);

has 'quantity' => (
    is => 'rw',
    isa => 'Int'
);




1;