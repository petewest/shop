class CreateRedemptions < ActiveRecord::Migration
  def change
    create_table :redemptions do |t|
      t.references :order, index: true
      t.references :gift_card, index: true
      t.references :currency, index: true
      t.integer :value

      t.timestamps
    end
  end
end
