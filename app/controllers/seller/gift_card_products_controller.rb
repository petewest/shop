class Seller::GiftCardProductsController < ApplicationController
  before_action :signed_in_seller
  before_action :find_gift_card_product

  def new
    @gift_card_product=GiftCardProduct.new
  end
  
  def create
    @gift_card_product=current_user.gift_card_products.new(gift_card_product_params)
    if @gift_card_product.save
      flash[:success]="Gift card denomination added"
      redirect_to seller_gift_card_products_path
    else
      flash.now[:danger]="Failed to add gift card denomination"
      render 'new'
    end
  end

  def index
    @gift_card_products=GiftCardProduct.order(:currency_id, :unit_cost)
  end

  def edit
    
  end

  def update
    if @gift_card_product.update_attributes(gift_card_product_params)
      flash[:success]="Gift card product updated"
      redirect_to seller_gift_card_products_path
    else
      flash.now[:danger]="Failed to save gift card product"
      render 'edit'
    end
  end

  def destroy
    if @gift_card_product.destroy
      flash[:success]="Gift card product deleted"
    else
      flash[:danger]="Couldn't delete gift card product"
    end
  rescue ActiveRecord::RecordNotDestroyed => e
    flash[:danger]=@gift_card_product.errors_on_associations.map{|k,v| "#{k.to_s.humanize}: #{v.join}"}.join(', ')
  ensure
    redirect_to seller_gift_card_products_path
  end

  

  private
    def gift_card_product_params
      params.require(:gift_card_product).permit(:currency_id, :unit_cost, :for_sale)
    end
    def find_gift_card_product
      @gift_card_product=GiftCardProduct.find(params[:id]) if params[:id]
    end
end
