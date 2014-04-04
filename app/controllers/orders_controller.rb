class OrdersController < ApplicationController
  before_action :signed_in_user

  def new
    @order=current_cart
  end

  def create
    @order=current_user.orders.new(order_params)
    if @order.save
      @order.placed!
      flash[:success]="Thank you for your order."
      self.current_cart=nil
      redirect_to @order
    else
      flash[:danger]="Order creation failed"
      render 'new'
    end
  end

  private
    
    def order_params
      params.require(:order).permit(line_items_attributes: [:product_id, :quantity])
    end

    def copy_cost_to_line_items(order)
      order.line_items.each(&:copy_cost_from_product)
    end
end
