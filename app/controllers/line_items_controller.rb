class LineItemsController < ApplicationController
  def new
    @product=Product.find(params[:product_id]) if params[:product_id]
    @line_item=current_cart.line_items.new(product: @product)
  end

  def create
    self.current_cart=current_cart if current_cart.save
    @line_item=current_cart.line_items.new(line_item_params)
    if @line_item.save
      flash[:success]="#{@line_item.product.name} added to cart"
      redirect_to products_path
    else
      flash[:danger]="Error adding item to cart"
      render 'new'
    end
  end

  private
    def line_item_params
      params.require(:line_item).permit(:product_id, :quantity)
    end
end
