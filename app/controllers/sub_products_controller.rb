class SubProductsController < ApplicationController
  before_action :signed_in_seller

  def new
    @product=Product.find(params[:product_id])
    @sub_product=@product.sub_products.new
  end

  def index
    @product=Product.find(params[:product_id])
    @sub_products=@product.sub_products
  end
end
