class AddRefsToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :billing, index: true
    add_reference :orders, :delivery, index: true
  end
end
