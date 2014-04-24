class Seller::ProductsController < ApplicationController
  before_action :signed_in_seller
  def index
    @products=Product.where(type: nil).includes(:stock_levels, sub_products: [:stock_levels]).page(params[:page])
  end
end
