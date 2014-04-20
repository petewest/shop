class AddStripeChargeRefToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :stripe_charge_reference, :string
  end
end
