class Seller::GiftCardsController < ApplicationController
  before_action :signed_in_seller
  def new
    @gift_card=GiftCard.new
  end
  def create
    @gift_card=current_user.gift_cards_bought.new(gift_card_params)
    if @gift_card.save
      flash[:success]="Gift card issued"
      redirect_to seller_gift_cards_path
    else
      flash.now[:danger]="Could not create gift card"
      render 'new'
    end
  end

  private
    def gift_card_params
      params.require(:gift_card).permit(:redeemer_id, :currency_id, :unit_cost)
    end
end
