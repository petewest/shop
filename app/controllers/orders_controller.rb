class OrdersController < ApplicationController
  before_action :signed_in_user, except: :cart

  def new
    @order=Order.new
  end

  def cart
    @order=Order.new(status: :cart)
    @order.line_items=order_from_cart
  end

  private
    def order_from_cart
      line_item_params.map{|li| LineItem.new(li) }
    end
end