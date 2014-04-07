class StockLevelsController < ApplicationController
  before_action :signed_in_seller
  before_action :product_from_params

  def index
    @stock_levels=@product.stock_levels.all
  end

  private
    def product_from_params
      @product=Product.find(params[:product_id])
    end
end
