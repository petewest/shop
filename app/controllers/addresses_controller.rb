class AddressesController < ApplicationController
  before_action :signed_in_user

  def index
    @addresses=current_user.addresses
  end

  def new
    @address=current_user.addresses.new
  end

  def create
    @address=current_user.addresses.new(address_params)
    if @address.save
      flash[:success]="Address #{@address.label} added to your address book"
      redirect_to addresses_url
    else
      flash.now[:danger]="Failed to add address"
      render 'new'
    end
  end


  private
    def address_params
      params.require(:address).permit(:label, :address, :default_billing, :default_delivery)
    end
end
