class RenameCostInProduct < ActiveRecord::Migration
  def change
    rename_column :products, :cost, :unit_cost
  end
end
