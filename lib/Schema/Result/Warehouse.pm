use utf8;
package Schema::Result::Warehouse;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Warehouse

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<warehouse>

=cut

__PACKAGE__->table("warehouse");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_unique>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_unique", ["name"]);

=head1 RELATIONS

=head2 inventories

Type: has_many

Related object: L<Schema::Result::Inventory>

=cut

__PACKAGE__->has_many(
  "inventories",
  "Schema::Result::Inventory",
  { "foreign.warehouse_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 warehouse_orders

Type: has_many

Related object: L<Schema::Result::WarehouseOrder>

=cut

__PACKAGE__->has_many(
  "warehouse_orders",
  "Schema::Result::WarehouseOrder",
  { "foreign.warehouse_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-10-26 17:12:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RajtjtgXkFSxtr6uBfF0FA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
