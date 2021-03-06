class StockLevelsController < ApplicationController
  before_action :signed_in_seller
  before_action :product_from_params
  before_action :stock_level_from_params

  def index
    @stock_levels=@product.stock_levels.order(due_at: :asc)
  end

  def new
    @stock_level=@product.stock_levels.new
  end

  def create
    @stock_level=@product.stock_levels.new(stock_level_params)
    if @stock_level.save
      flash.now[:success]="Stock added"
      respond_to do |format|
        format.html { redirect_to product_stock_levels_url(@product) }
        format.js
      end
    else
      flash.now[:danger]="Error saving stock"
      render 'new'
    end
  end

  def destroy
    @product=@stock_level.product
    if @stock_level.destroy
      flash.now[:success]="Stock level removed"
    else
      flash.now[:danger]="Could not delete stock: " + @stock_level.errors.full_messages.join(", ")
    end
    respond_to do |format|
      format.html { redirect_to product_stock_levels_url(@product) }
      format.js
    end
  end

  def edit

  end

  def update
    if @stock_level.update_attributes(stock_level_edit_params)
      flash.now[:success]=I18n.t('stock_levels.update.success')
      respond_to do |format|
        format.html { redirect_to product_stock_levels_path(@stock_level.product) }
        format.js
      end
    else
      flash.now[:danger]=I18n.t('stock_levels.update.failure')
      render 'edit'
    end
  end

  private
    def product_from_params
      @product=Product.find(params[:product_id]) if params[:product_id]
    end
    def stock_level_params
      params.require(:stock_level).permit(:due_at, :start_quantity, :expires_at, :allow_preorder)
    end
    def stock_level_edit_params
      stock_level_params.except(:start_quantity)
    end
    def stock_level_from_params
      @stock_level=StockLevel.find(params[:id]) if params[:id]
    end
end
