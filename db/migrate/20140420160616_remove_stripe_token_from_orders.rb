class RemoveStripeTokenFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :stripe_token, :string
  end
end
