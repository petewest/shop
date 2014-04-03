class AddTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :type, :string
  end
end
