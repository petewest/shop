class ProductsController < ApplicationController
  before_action :signed_in_seller, except: [:index, :show, :buy]
  before_action :product_from_params, except: [:index, :new, :create]

  def index
    @products=Product.includes(:images, :main_image).page(params[:page])
  end

  def new
    @product=Product.new
    @product.images.new
    @product.build_cost
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

  def buy
    quantity=params.try(:[],:cart).try(:[],:quantity).to_i
    if quantity<=0
      flash[:warning]="Quantity needed"
    else
      flash.now[:success]="#{view_context.pluralize(quantity, @product.name)} added to cart"
      add_to_cart(product: @product, quantity: quantity)
    end
    respond_to do |format|
      format.html { redirect_to products_path }
      format.js
    end
  end


  private
    def product_params
      params[:product][:cost_attributes][:value].gsub!(/#{I18n.t("number.parse")}/,"") if params.try(:[], :product).try(:[], :cost_attributes).try(:[], :value)
      params.require(:product).permit(:name, :description, images_attributes: [:id, :image, :_destroy], cost_attributes: [:id, :currency_id, :value])
    end
    def product_from_params
      @product=Product.find(params[:id])
    end
end
