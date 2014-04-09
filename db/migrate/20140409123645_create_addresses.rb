class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :user, index: true
      t.string :label
      t.boolean :default_billing
      t.boolean :default_delivery
      t.text :address

      t.timestamps
    end
    add_index :addresses, [:user_id, :default_billing]
    add_index :addresses, [:user_id, :default_delivery]
  end
end
