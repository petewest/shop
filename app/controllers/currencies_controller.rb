class CurrenciesController < ApplicationController
  before_action :signed_in_seller
  def index
    @currencies=Currency.all
  end

  def edit
    @currency=Currency.find(params[:id])
  end
end
