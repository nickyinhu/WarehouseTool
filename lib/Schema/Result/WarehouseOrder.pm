use utf8;
package Schema::Result::WarehouseOrder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::WarehouseOrder

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<warehouse_order>

=cut

__PACKAGE__->table("warehouse_order");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 warehouse_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 order_status

  data_type: 'text'
  default_value: 'open'
  is_nullable: 0

=head2 order_total

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "warehouse_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "order_status",
  { data_type => "text", default_value => "open", is_nullable => 0 },
  "order_total",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 order_details

Type: has_many

Related object: L<Schema::Result::OrderDetail>

=cut

__PACKAGE__->has_many(
  "order_details",
  "Schema::Result::OrderDetail",
  { "foreign.order_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-10-26 17:26:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZDnj1WECm4+UTA2s/1VaYg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
