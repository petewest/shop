class AddExpiresAtToStockLevels < ActiveRecord::Migration
  def change
    add_column :stock_levels, :expires_at, :datetime
  end
end
