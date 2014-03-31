class OrdersController < ApplicationController
  before_action :signed_in_user

  def new
    @order=Order.new
    @order.line_items=order_from_cart
  end

  def create
    @order=current_user.orders.new(order_params)
    @order.status=:placed
    if @order.save
      flash[:success]="Thank you for your order."
      self.current_cart={}
      redirect_to @order
    else
      flash[:danger]="Order creation failed"
      render 'new'
    end
  end

  private
    def order_from_cart
      line_item_params.map{|li| LineItem.new(li) }
    end

    def order_params
      params.require(:order).permit(line_items_attributes: [:product_id, :quantity])
    end

      def line_item_params
        current_cart.map{ |key, item| ActionController::Parameters.new(item).permit(:product_id, :quantity) }
      end
end
