class AddCurrencyToGiftCard < ActiveRecord::Migration
  def change
    add_reference :gift_cards, :currency, index: true
  end
end
