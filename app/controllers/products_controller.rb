class ProductsController < ApplicationController
  before_action :signed_in_seller, except: [:index, :show, :buy]
  before_action :product_from_params, except: [:index, :new, :create]

  def index
    @products=Product.includes(:images, :main_image, :current_stock).page(params[:page])
  end

  def new
    @product=Product.new
    @product.images.new
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

  def show
  end

  def destroy
    if @product.destroy
      flash[:success]="Product deleted"
    else
      flash[:danger]="Product deletion failed"
    end
    redirect_to products_path
  end

  def edit
  end

  def update
    if @product.update_attributes(product_params)
      flash[:success]="Product details saved"
      redirect_to @product
    else
      flash.now[:danger]="Product detail update failed"
      render 'edit'
    end
  end

  private
    def product_params
      params[:product][:unit_cost].gsub!(/#{I18n.t("number.parse")}/,"") if params.try(:[], :product).try(:[], :unit_cost)
      params.require(:product).permit(:name, :description, :currency_id, :unit_cost, :weight, images_attributes: [:id, :image, :_destroy])
    end
    def product_from_params
      @product=Product.find(params[:id])
    end
end
