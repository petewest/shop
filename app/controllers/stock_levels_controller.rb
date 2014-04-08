class StockLevelsController < ApplicationController
  before_action :signed_in_seller
  before_action :product_from_params

  def index
    @stock_levels=@product.stock_levels.order(due_at: :asc)
  end

  def new
    @stock_level=@product.stock_levels.new
  end

  def create
    @stock_level=@product.stock_levels.new(stock_level_params)
    if @stock_level.save
      flash[:success]="Stock added"
      redirect_to product_stock_levels_url(@product)
    else
      flash.now[:danger]="Error saving stock"
      render 'new'
    end
  end

  private
    def product_from_params
      @product=Product.find(params[:product_id])
    end
    def stock_level_params
      params.require(:stock_level).permit(:due_at, :start_quantity, :current_quantity, :allow_preorder)
    end
end
