class Seller::OrdersController < ApplicationController
  before_action :signed_in_seller
  before_action :order_from_params, only: [:update, :show]

  def index
    @orders=Order.includes(:user)
    if params[:stock_level_id]
      a_table=Allocation.arel_table
      @orders=@orders.joins(:allocations).where(a_table[:stock_level_id].eq(params[:stock_level_id]))
    end
    @orders=@orders.all
  end

  def update
    if @order.update_attributes(order_params)
      flash.now[:success]="Order updated"
      case @order.status
      when "dispatched"
        OrderMailer.dispatch_email(@order).deliver
      end
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
