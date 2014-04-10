class AddAddressableToAddresses < ActiveRecord::Migration
  def change
    add_reference :addresses, :addressable, polymorphic: true, index: true
    Address.update_all("addressable_id=user_id, addressable_type='User'")
    remove_column :addresses, :user_id
  end
end
