class CartController < ApplicationController
  def index
    @products=Product.find(current_cart.map{|k,v| v["product_id"]})
  end

  def destroy
    remove_from_cart(params[:id])
    flash.now[:success]="Item removed from cart"
    respond_to do |format|
      format.html { redirect_to cart_path }
      format.js
    end
  end

  def update
    self.current_cart=current_cart.merge(params[:id] => current_cart[params[:id]].merge(cart_params)) if current_cart.has_key?(params[:id])
    respond_to do |format|
      format.html {redirect_to cart_path}
    end
  end

  private
    def cart_params
      params.permit(:quantity)
    end
end
