class AddUniqueIndexToCostable < ActiveRecord::Migration
  def change
    remove_index :costs, [:costable_id, :costable_type]
    add_index :costs, [:costable_id, :costable_type] , unique: true
  end
end
