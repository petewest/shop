class OrdersController < ApplicationController
  before_action :signed_in_user

  def index
    @orders=current_user.orders.includes(line_items: [:product, :currency]).all
  end

  def set_current
    @order=current_user.carts.find_by(id: params[:id])
    if @order
      flash[:success]="Previous cart resumed"
      self.current_cart=@order
    else
      flash[:warning]="Cart not found"
    end
    redirect_to checkout_url and return if params[:submit]=="Checkout"
    redirect_to cart_url
  end
end
