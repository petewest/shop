class CreateStockLevels < ActiveRecord::Migration
  def change
    create_table :stock_levels do |t|
      t.references :product, index: true
      t.datetime :due_at
      t.integer :start_quantity
      t.integer :current_quantity

      t.timestamps
    end
  end
end
