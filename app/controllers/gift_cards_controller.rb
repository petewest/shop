class GiftCardsController < ApplicationController
  before_action :signed_in_user
  def index
    @gift_cards=current_user.gift_cards_redeemed
  end
end
