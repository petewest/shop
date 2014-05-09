class AddAllocationToGiftCard < ActiveRecord::Migration
  def change
    add_reference :gift_cards, :allocation, index: true
  end
end
