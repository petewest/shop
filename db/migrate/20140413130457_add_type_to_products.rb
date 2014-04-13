class AddTypeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :type, :string
    add_index :products, :type
    add_reference :products, :master_product, index: true
  end
end
