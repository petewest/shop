class CartController < ApplicationController
  def index
    @products=Product.find(current_cart.map{|k,v| v["product_id"]})
  end

  def destroy
    remove_from_cart(params[:id])
    flash.now[:success]="Item removed from cart"
    respond_to do |format|
      format.html { redirect_to cart_index_path }
      format.js
    end
  end

  def update
    @cart_item=current_cart[params[:id]]
    @products=[Product.find(@cart_item["product_id"])]
    if !@cart_item or params[:cart][:quantity].to_i<=0
      flash.now[:warning]="Error saving changes"
    else
      @cart_item.merge!(cart_params)
      self.current_cart=current_cart.merge(params[:id] => @cart_item)
      flash.now[:success]="Cart updated"
    end
    respond_to do |format|
      format.html {redirect_to cart_index_path}
      format.js
    end
  end

  private
    def cart_params
      params.require(:cart).permit(:quantity)
    end
end
