class RenameCostToUnitCost < ActiveRecord::Migration
  def change
    rename_column :postage_costs, :cost, :unit_cost
  end
end
