class CreateAllocations < ActiveRecord::Migration
  def change
    create_table :allocations do |t|
      t.references :line_item, index: true
      t.references :stock_level, index: true
      t.integer :quantity

      t.timestamps
    end
    add_index :allocations, [:line_item_id, :stock_level_id], unique: true
  end
end
