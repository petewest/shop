class GiftCardProductsController < ApplicationController
  before_action :signed_in_seller
  def new
    @gift_card_product=GiftCardProduct.new
  end
end
