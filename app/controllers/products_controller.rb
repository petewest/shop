class ProductsController < ApplicationController
  before_action :signed_in_seller, except: [:index, :show]
  before_action :product_from_params, except: [:index, :new, :create]

  def index
    @products=Product.includes(:main_image, :currency).where(type: nil).page(params[:page])
  end

  def new
    @product=Product.new
    @product.images.new
  end

  def create
    if product_params[:master_product_id]
      @product=current_user.sub_products.new(product_params)
    end
    @product||=current_user.products.new(product_params)
    if @product.save
      flash[:success]="New product created"
      redirect_to @product
    else
      flash.now[:danger]="Product creation failed"
      render 'new'
    end
  end

  def show
    @description=RedCloth.new(@product.description, [:sanitize_html])
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
    @product.images.new
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
      params.require(:product).permit(:name, :description, :currency_id, :unit_cost, :weight, :master_product_id, images_attributes: [:id, :image, :main, :_destroy])
    end
    def product_from_params
      @product=Product.find(params[:id])
    end
end
