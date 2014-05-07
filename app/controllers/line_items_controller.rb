class LineItemsController < ApplicationController
  def new
    @product=Product.find(params[:product_id]) if params[:product_id]
    @product=GiftCardProduct.find(params[:gift_card_product_id]) if params[:gift_card_product_id]
    @line_item=current_cart.line_items.new(product: @product).copy_cost_from_product
    @stock_level=@product.stock_levels.current.first
  end

  def create
    self.current_cart=current_cart if current_cart.save
    @line_item=current_cart.line_items.new(line_item_params)
    if request.xhr? and params[:submitted_from]=~/quantity/
      # if it's been submitted by changing the quantity we won't actually save the item
      render 'new'
    elsif @line_item.save
      # We've added a new line item, but the current_cart is still cached with the old value
      current_cart.reload
      flash.now[:success]="#{@line_item.product.name} added to cart"
      respond_to do |format|
        format.html { redirect_to products_path }
        format.js
      end
    else
      if current_cart.line_items.any? and @line_item_duplicate=current_cart.line_items.find_by(line_item_params.except(:quantity))
        @line_item_duplicate.errors[:product_id]=@line_item.errors[:product_id]
      else
        flash.now[:danger]="Error adding item to cart"
      end
      render 'new'
    end
  end

  def update
    @line_item=current_cart.line_items.find(params[:id])
    # if someone has changed the quantity, we'll just pretend to update
    if request.xhr? and params[:submitted_from]=~/quantity/
      # soft update without save
      @line_item.assign_attributes(line_item_params)
      # and refresh the display
      render 'new'
    elsif @line_item.update_attributes(line_item_params)
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
