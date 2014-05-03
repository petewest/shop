class Seller::UsersController < ApplicationController
  before_action :signed_in_seller

  def index
    @users=User.page(params[:page])
  end
end
