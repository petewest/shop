class CartsController < ApplicationController
  before_action :signed_in_user, only: [:checkout, :confirm]

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
  end

  def confirm
    @cart=current_cart
    if @cart.user and !current_user?(@cart.user)
      redirect_to root_url
      return
    end
    @cart.user=current_user
    @cart.status=:placed
    if @cart.save
      flash[:success]="Thank you for your order!"
      redirect_to order_path(@cart)
    else
      flash[:danger]="Error processing cart, please sign out and back in"
      redirect_to cart_url
    end
  end

  private
    def cart_params
      params.require(:cart).permit(line_items_attributes: [:id, :product_id, :quantity, :_destroy])
    end
end
