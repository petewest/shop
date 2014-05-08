class Seller::GiftCardsController < ApplicationController
  before_action :signed_in_seller
  def new
    @gift_card=GiftCard.new
  end
end
