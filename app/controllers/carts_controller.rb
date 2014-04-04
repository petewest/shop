class CartsController < ApplicationController
  before_action :signed_in_user, only: [:checkout]

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

  private
    def cart_params
      params.require(:cart).permit(line_items_attributes: [:id, :product_id, :quantity, :_destroy])
    end
end
