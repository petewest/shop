class SubProductsController < ApplicationController
  before_action :signed_in_seller
  before_action :product_from_params, only: [:new, :index, :create]

  def new
    @sub_product=@product.sub_products.new
  end

  def index
    @sub_products=@product.sub_products
  end

  def create
    @sub_product=current_user.sub_products.new(sub_product_params)
    @sub_product.master_product=@product
    if @sub_product.save
      flash[:success]="Sub-product created"
      redirect_to [@product, :sub_products]
    else
      flash.now[:danger]="Creation failed"
      render 'new'
    end
  end


  private
    def product_from_params
      @product=Product.find(params[:product_id])
    end

    def sub_product_params
      params[:sub_product][:unit_cost].gsub!(/#{I18n.t("number.parse")}/,"") if params.try(:[], :sub_product).try(:[], :unit_cost)
      params.require(:sub_product).permit(:name, :description, :currency_id, :unit_cost, :weight, images_attributes: [:id, :image, :_destroy])
    end
end
