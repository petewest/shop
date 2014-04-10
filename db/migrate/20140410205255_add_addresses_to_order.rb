class AddAddressesToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_address, :text
    add_column :orders, :billing_address, :text
    add_reference :addresses, :user, index: true
    Address.update_all("user_id=addressable_id")
    remove_column :addresses, :addressable_id
  end
end
