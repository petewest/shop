class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :user, index: true
      t.integer :status
      t.datetime :placed_at
      t.datetime :paid_at
      t.datetime :dispatched_at

      t.timestamps
    end
    add_index :orders, :status
  end
end
