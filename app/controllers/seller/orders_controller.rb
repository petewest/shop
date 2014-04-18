class Seller::OrdersController < ApplicationController
  before_action :signed_in_seller
  before_action :order_from_params, only: [:update, :show]

  def index
    @orders=Order
    @orders=StockLevel.find(params[:stock_level_id]).orders if params[:stock_level_id]
    @orders=@orders.all
  end

  def update
    if @order.update_attributes(order_params)
      flash.now[:success]="Order updated"
    else
      flash.now[:danger]="Update failed"
    end
    respond_to do |format|
      format.html { redirect_to seller_orders_url }
      format.js
    end
  end

  def show
  end

  private
    def order_from_params
      @order=Order.find(params[:id])
    end
    def order_params
      params.require(:order).permit(:status)
    end
end
