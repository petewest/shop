class ChangeProductToPolymorphic < ActiveRecord::Migration
  def change
    rename_column :line_items, :product_id, :buyable_id
    add_column :line_items, :buyable_type, :string, null: false, default: "Product"
    add_index :line_items, [:buyable_type, :buyable_id]
  end
end
