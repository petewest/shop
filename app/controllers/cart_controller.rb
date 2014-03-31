class CartController < ApplicationController
  def index
    @products=Product.find(current_cart.map{|k,v| v[:product_id]})
  end

  def destroy
    remove_from_cart(params[:id])
    redirect_to cart_path
  end
end
