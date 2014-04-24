class StockLevelsController < ApplicationController
  before_action :signed_in_seller
  before_action :product_from_params, except: [:destroy]
  before_action :stock_level_from_params, only: [:destroy]

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

  private
    def product_from_params
      @product=Product.find(params[:product_id])
    end
    def stock_level_params
      params.require(:stock_level).permit(:due_at, :start_quantity, :current_quantity, :allow_preorder)
    end
    def stock_level_from_params
      @stock_level=StockLevel.find(params[:id])
    end
end
