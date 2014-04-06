class CurrenciesController < ApplicationController
  before_action :signed_in_seller
  before_action :currency_from_params, only: [:edit, :update, :destroy]

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

  def create
    @currency=Currency.new(currency_params)
    if @currency.save
      flash.now[:success]="New currency #{@currency.iso_code} created"
      respond_to do |format|
        format.html { redirect_to currencies_url }
        format.js
      end
    else
      flash.now[:danger]="Currency creation failed"
      render 'new'
    end
  end

  def destroy
    if @currency.destroy
      flash[:success]="Currency deleted"
      respond_to do |format|
        format.js
        format.html {redirect_to currencies_url}
      end
    else
      flash[:danger]="Currency deletion failed"
      respond_to do |format|
        format.html {redirect_to currencies_url}
        format.js { render partial: 'shared/refresh_flash' }
      end
    end
  end


  private
    def currency_from_params
      @currency=Currency.find(params[:id])
    end
    def currency_params
      params.require(:currency).permit(:iso_code, :symbol, :decimal_places)
    end
end
