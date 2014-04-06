class CurrenciesController < ApplicationController
  before_action :signed_in_seller
  before_action :currency_from_params, only: [:edit, :update]

  def index
    @currencies=Currency.all
  end

  def edit
  end

  def update
    if @currency.update_attributes(currency_params)
      flash.now[:success]="Currency updated"
      respond_to do |format|
        format.html { redirect_to currencies_url }
        format.js
      end
    else
      flash.now[:danger]="Update failed"
      render 'edit'
    end
  end

  def new
    @currency=Currency.new
  end


  private
    def currency_from_params
      @currency=Currency.find(params[:id])
    end
    def currency_params
      params.require(:currency).permit(:iso_code, :symbol, :decimal_places)
    end
end
