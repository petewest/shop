class ProductsController < ApplicationController
  def index
    @products=Product.page(params[:page])
  end
end
