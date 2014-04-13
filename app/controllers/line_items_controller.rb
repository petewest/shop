class LineItemsController < ApplicationController
  def new
    @product=Product.find(params[:product_id]) if params[:product_id]
    @line_item=current_cart.line_items.new(product: @product).copy_cost_from_product
    @stock_level=@product.stock_levels.current.first
  end

  def create
    self.current_cart=current_cart if current_cart.save
    @line_item=current_cart.line_items.new(line_item_params)
    if @line_item.save
      flash.now[:success]="#{@line_item.product.name} added to cart"
      respond_to do |format|
        format.html { redirect_to products_path }
        format.js
      end
    else
      if @line_item_duplicate=current_cart.line_items.find_by(line_item_params.except(:quantity))
        @line_item_duplicate.errors[:product_id]=@line_item.errors[:product_id]
      else
        flash.now[:danger]="Error adding item to cart"
      end
      render 'new'
    end
  end

  def update
    @line_item=current_cart.line_items.find(params[:id])
    if @line_item.update_attributes(line_item_params)
      flash.now[:success]="Cart updated"
      respond_to do |format|
        format.html { redirect_to products_path }
        format.js
      end
    else
      flash[:danger]="Cart item update failed"
      render 'new'
    end
  end

  private
    def line_item_params
      params.require(:line_item).permit(:product_id, :quantity)
    end
end
