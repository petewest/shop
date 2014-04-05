class RemoveCostColumnFromLineItems < ActiveRecord::Migration
  def change
    remove_column :line_items, :cost, :integer
  end
end
