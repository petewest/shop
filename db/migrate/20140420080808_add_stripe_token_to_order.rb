class AddStripeTokenToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :stripe_token, :string
  end
end
