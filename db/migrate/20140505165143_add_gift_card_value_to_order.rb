class AddGiftCardValueToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :gift_card_value, :integer, default: 0
  end
end
