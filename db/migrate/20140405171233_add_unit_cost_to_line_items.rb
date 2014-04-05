class AddUnitCostToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :unit_cost, :integer
  end
end
