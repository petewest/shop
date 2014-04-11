class RemoveAddressesFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :delivery_address, :string
    remove_column :orders, :billing_address, :string
  end
end
