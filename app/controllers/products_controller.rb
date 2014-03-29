class ProductsController < ApplicationController
  before_action :signed_in_seller, except: [:index, :show]

  def index
    @products=Product.page(params[:page])
  end

  def new
    @product=Product.new
  end
end
