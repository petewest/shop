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
    #setting quantity to be zero should say destroy
    params[:cart][:line_items_attributes].each do |k,v|
      v[:_destroy]='1' if v[:quantity]=="0"
    end if params[:cart]
    if @cart.update_attributes(cart_params)
      if params[:commit]=="Checkout"
        render 'redirect_to_checkout' and return if request.xhr?
        redirect_to checkout_url and return
      else
        flash[:success]="Cart updated"
      end
    else
      flash.now[:danger]="Couldn't update cart contents"
      render 'show' and return
    end
    redirect_to cart_path
  end

  def checkout
    @cart=current_cart
    @cart.delivery||=OrderAddress.new(source_address: current_user.addresses.delivery.first)
    @cart.billing||=OrderAddress.new(source_address: current_user.addresses.billing.first)
  end

  def update_address
    @cart=current_cart
    @modes=address_params
    @cart.assign_attributes(address_params)
    @cart.billing.copy_address if address_params[:billing_attributes]
    @cart.delivery.copy_address if address_params[:delivery_attributes]
    if @cart.save
      flash.now[:success]="Address set"
    else
      flash.now[:danger]="Failed to set address"
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
    @cart.delivery||=OrderAddress.new(source_address: current_user.addresses.delivery.first).copy_address
    @cart.billing||=OrderAddress.new(source_address: current_user.addresses.billing.first).copy_address
    @cart.status=:placed
    if @cart.save
      flash[:success]="Thank you for your order!"
      OrderMailer.confirmation_email(@cart).deliver
      redirect_to order_path(@cart)
    else
      flash.now[:danger]="Error processing cart"
      render 'checkout'
    end
  end

  private
    def cart_params
      params.require(:cart).permit(line_items_attributes: [:id, :product_id, :quantity, :_destroy])
    end

    def address_params
      params.require(:cart).permit(delivery_attributes: [:id, :source_address_id], billing_attributes: [:id, :source_address_id])
    end
end
