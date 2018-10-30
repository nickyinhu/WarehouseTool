use utf8;
package Schema::Result::Item;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Item

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<item>

=cut

__PACKAGE__->table("item");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 upc

  data_type: 'text'
  is_nullable: 0

=head2 price

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "upc",
  { data_type => "text", is_nullable => 0 },
  "price",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<upc_unique>

=over 4

=item * L</upc>

=back

=cut

__PACKAGE__->add_unique_constraint("upc_unique", ["upc"]);

=head1 RELATIONS

=head2 inventories

Type: has_many

Related object: L<Schema::Result::Inventory>

=cut

__PACKAGE__->has_many(
  "inventories",
  "Schema::Result::Inventory",
  { "foreign.item_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 order_details

Type: has_many

Related object: L<Schema::Result::OrderDetail>

=cut

__PACKAGE__->has_many(
  "order_details",
  "Schema::Result::OrderDetail",
  { "foreign.item_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-10-26 21:45:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:69L9CK6nnDq4+PpTz3wAOA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
