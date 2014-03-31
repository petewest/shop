class OrdersController < ApplicationController
  before_action :signed_in_user

  def new
    @order=Order.new
    @order.line_items=order_from_cart
  end

  private
    def order_from_cart
      line_item_params.map{|li| LineItem.new(li) }
    end
end
