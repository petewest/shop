class AddressesController < ApplicationController
  before_action :signed_in_user

  def index
    @addresses=current_user.addresses
  end

  def new
    @address=current_user.addresses.new
  end
end
