class AddCostToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :unit_cost, :integer
  end
end
