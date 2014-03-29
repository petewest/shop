class ProductsController < ApplicationController
  before_action :signed_in_seller, except: [:index, :show]

  def index
    @products=Product.page(params[:page])
  end

  def new
    @product=Product.new
  end

  def create
    @product=current_user.products.new(product_params)
    if @product.save
      flash[:success]="New product created"
      redirect_to @product
    else
      flash.now[:danger]="Product creation failed"
      render 'new'
    end
  end


  private
    def product_params
      params.require(:product).permit(:name, :description)
    end
end
