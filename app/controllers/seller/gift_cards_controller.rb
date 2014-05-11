class Seller::GiftCardsController < ApplicationController
  before_action :signed_in_seller
  before_action :find_gift_card

  def new
    @redeemer=User.find(params[:user_id]) if params[:user_id]
    @gift_card=@redeemer.gift_cards_redeemed.new if @redeemer.present?
    @gift_card||=GiftCard.new
  end

  def create
    # This will act as if the seller bought the gift card
    @gift_card=current_user.gift_cards_bought.new(gift_card_params)
    if @gift_card.save
      flash[:success]="Gift card issued"
      redirect_to seller_gift_cards_path
    else
      flash.now[:danger]="Could not create gift card"
      render 'new'
    end
  end

  def index
    @gift_cards=GiftCard
    @gift_cards=@gift_cards.where(allocation_id: params[:allocation_id]) if params[:allocation_id]
    @gift_cards=@gift_cards.page(params[:page])
  end

  def edit
  end

  def update
    if @gift_card.update_attributes(gift_card_params)
      flash[:success]="Gift card updated"
      redirect_to seller_gift_cards_path
    else
      flash.now[:danger]="Gift card update failed"
      render 'edit'
    end
  end

  private
    def gift_card_params
      params.require(:gift_card).permit(:redeemer_id, :currency_id, :start_value)
    end
    def find_gift_card
      @gift_card=GiftCard.find(params[:id]) if params[:id]
    end
end
