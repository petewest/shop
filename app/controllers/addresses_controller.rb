class AddressesController < ApplicationController
  before_action :signed_in_user
  before_action :user_address_from_params, only: [:edit, :update, :destroy]

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

  def edit
  end

  def update
    if @address.update_attributes(address_params)
      flash[:success]="Address details saved"
      redirect_to addresses_url
    else
      flash.now[:danger]="Update failed"
      render 'edit'
    end
  end

  def destroy
    if @address.destroy
      flash[:success]="Address removed"
    else
      flash[:danger]="Address deletion failed"
    end
    redirect_to addresses_url
  end


  private
    def address_params
      params.require(:address).permit(:label, :address, :default_billing, :default_delivery)
    end
    def user_address_from_params
      @address=current_user.addresses.find(params[:id])
    end
end
