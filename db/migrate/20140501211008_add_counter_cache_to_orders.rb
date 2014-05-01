class AddCounterCacheToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :line_items_count, :integer, default: 0, null: false
    Order.pluck(:id).each do |id|
      Order.reset_counters(id, :line_items)
    end
  end
  def down
    remove_column :orders, :line_items_count
  end
end
