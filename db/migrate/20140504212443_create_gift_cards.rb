class CreateGiftCards < ActiveRecord::Migration
  def change
    create_table :gift_cards do |t|
      t.references :buyer, index: true
      t.references :redeemer, index: true
      t.string :token
      t.integer :start_value
      t.integer :current_value
      t.datetime :expires_at

      t.timestamps
    end
    add_index :gift_cards, :token
  end
end
