class DeleteCostsTableAddColumns < ActiveRecord::Migration
  def change
    drop_table :costs
    add_column :products, :cost, :integer
    add_column :products, :currency_id, :integer, index: true
    add_column :line_items, :cost, :integer
    add_column :line_items, :currency_id, :integer, index: true
  end
end
