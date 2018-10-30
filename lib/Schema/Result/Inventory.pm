use utf8;
package Schema::Result::Inventory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Inventory

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<inventory>

=cut

__PACKAGE__->table("inventory");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 warehouse_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 item_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 available_quantity

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 reserved_quantity

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "warehouse_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "item_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "available_quantity",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "reserved_quantity",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 item

Type: belongs_to

Related object: L<Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "item",
  "Schema::Result::Item",
  { id => "item_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 warehouse

Type: belongs_to

Related object: L<Schema::Result::Warehouse>

=cut

__PACKAGE__->belongs_to(
  "warehouse",
  "Schema::Result::Warehouse",
  { id => "warehouse_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-10-26 13:58:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:noVz1d3+oVaH+UGBUdjzbQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
