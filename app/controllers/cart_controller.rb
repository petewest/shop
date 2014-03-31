class CartController < ApplicationController
  def index
    @products=Product.find(current_cart.map{|k,v| v["product_id"]})
  end

  def destroy
    remove_from_cart(params[:id])
    flash[:success]="Item removed from cart"
    respond_to do |format|
      format.html { redirect_to cart_path }
      format.js
    end
  end
end
