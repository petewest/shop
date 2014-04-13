class SubProductsController < ApplicationController
  before_action :signed_in_seller
  before_action :product_from_params, only: [:new, :index, :create]

  def new
    @sub_product=@product.sub_products.new
    @sub_product.images.new
  end

  def index
    @sub_products=@product.sub_products
  end

  private
    def product_from_params
      @product=Product.find(params[:product_id])
    end
end
