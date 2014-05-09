class AddTypeToAllocations < ActiveRecord::Migration
  def change
    add_column :allocations, :type, :string
    add_index :allocations, :type
  end
end
