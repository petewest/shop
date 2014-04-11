class CreateOrderAddresses < ActiveRecord::Migration
  def change
    create_table :order_addresses do |t|
      t.references :source_address, index: true
      t.text :address

      t.timestamps
    end
  end
end
