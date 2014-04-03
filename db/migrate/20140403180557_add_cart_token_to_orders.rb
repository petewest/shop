class AddCartTokenToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :cart_token, :string
    add_index :orders, :cart_token, unique: true, where: "type='Cart'"
  end
end
