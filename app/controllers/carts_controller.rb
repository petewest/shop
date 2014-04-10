class CartsController < ApplicationController
  before_action :signed_in_user, only: [:checkout, :confirm, :update_address]

  def show
    @cart=current_cart
  end

  def destroy
    if current_cart.user==current_user and current_cart.destroy
      flash[:success]="Cart cleared!"
    else
      flash[:danger]="Error removing cart"
    end
    self.current_cart=nil
    redirect_to root_url
  end

  def update
    @cart=current_cart
    if @cart.update_attributes(cart_params)
      redirect_to checkout_path and return if params[:commit]=="Checkout"
      flash[:success]="Cart updated"
    else
      flash.now[:danger]="Couldn't update cart contents"
      render 'show'
    end
    redirect_to cart_path
  end

  def checkout
    @cart=current_cart
    @delivery_address=current_cart.delivery_address || current_user.addresses.delivery.first.try(:address)
    @billing_address=current_cart.billing_address || current_user.addresses.billing.first.try(:address)
  end

  def update_address
    #there must be a better way of doing this
    @cart=current_cart
    @modes=address_params
    @modes.each do |k,v|
      @cart[k]=current_user.addresses.find(v).try(:address)
    end
    if @cart.save
      flash[:success]="Address set"
    else
      flash[:danger]="Failed to set address"
    end
    respond_to do |format|
      format.html { redirect_to checkout_path}
      format.js
    end
  end

  def confirm
    @cart=current_cart
    if @cart.user and !current_user?(@cart.user)
      redirect_to root_url
      return
    end
    @cart.user=current_user
    @cart.delivery_address||=current_user.addresses.delivery.first.try(:address)
    @cart.billing_address||=current_user.addresses.billing.first.try(:address)
    @cart.status=:placed
    if @cart.save
      flash[:success]="Thank you for your order!"
      redirect_to order_path(@cart)
    else
      flash.now[:danger]="Error processing cart"
      render 'show'
    end
  end

  private
    def cart_params
      params.require(:cart).permit(line_items_attributes: [:id, :product_id, :quantity, :_destroy])
    end

    def address_params
      params.require(:cart).permit(:delivery_address, :billing_address)
    end
end
