class CartController < ApplicationController

  def index
    @line_items=line_items_from_cart
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
    if !@cart_item or params[:cart][:quantity].to_i<=0
      flash.now[:warning]="Error saving changes"
    else
      @cart_item.merge!(cart_params)
      @cart_item["quantity"]=@cart_item["quantity"].to_i+1 if params[:change_quantity]=="+"
      @cart_item["quantity"]=@cart_item["quantity"].to_i-1 if params[:change_quantity]=="-"
      self.current_cart=current_cart.merge(params[:id] => @cart_item)
      @line_items=line_items_from_cart
      @line_item=@line_items.find{|i| i.product_id==@cart_item["product_id"]}
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
