class Seller::OrdersController < ApplicationController
  before_action :signed_in_seller
  before_action :order_from_params, only: [:update, :show]

  def index
    @orders=Order.index_scope.includes(:user)
    @orders=@orders.where(status: Order.statuses[params[:order_status]]) if params[:order_status] and Order.statuses.has_key?(params[:order_status])
    #"status pending" is any order that can flow to "status"
    if params[:status_pending] and Order.statuses.has_key?(params[:status_pending])
      #Find the order flows that'll permit this destination
      flows=Order.allowed_status_flows.select do |status, flow|
        #Allow for single flows by splatting to array
        flow=*flow
        #Check if this status has the desired status in its flow
        flow.include?(params[:status_pending].to_sym)
      end
      #Convert these symbols to enum values
      numeric_statuses=Order.statuses.slice(*flows.keys).values
      #Filter the orders by these statuses
      @orders=@orders.where(status: numeric_statuses)
    end
    if params[:stock_level_id]
      a_table=Allocation.arel_table
      @orders=@orders.joins(:allocations).where(a_table[:stock_level_id].eq(params[:stock_level_id]))
    end
    @orders=@orders.page(params[:page])
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
