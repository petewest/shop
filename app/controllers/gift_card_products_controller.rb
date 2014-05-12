class GiftCardProductsController < ApplicationController
  before_action :signed_in_user
  def index
    @gift_card_products=GiftCardProduct.for_sale.all
  end
end
