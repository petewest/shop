class AddCurrencyToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :currency, index: true
  end
end
