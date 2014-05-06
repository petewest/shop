class Seller::GiftCardProductsController < ApplicationController
  before_action :signed_in_seller

  def new
    @gift_card_product=GiftCardProduct.new
  end
  
  def create
    @gift_card_product=current_user.gift_card_products.new(gift_card_product_params)
    if @gift_card_product.save
      flash[:success]="Gift card denomination added"
    else
      flash[:danger]="Failed to add gift card denomination"
    end
    redirect_to root_url
  end

  private
    def gift_card_product_params
      params.require(:gift_card_product).permit(:currency_id, :unit_cost)
    end
end
