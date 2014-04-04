class LineItemsController < ApplicationController
  def new
    @product=Product.find(params[:product_id]) if params[:product_id]
    @line_item=current_cart.line_items.new(product: @product)
  end
end
