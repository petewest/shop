class AddPreOrderToStockLevels < ActiveRecord::Migration
  def change
    add_column :stock_levels, :allow_preorder, :boolean, default: false
  end
end
