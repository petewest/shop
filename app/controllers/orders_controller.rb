class OrdersController < ApplicationController
  before_action :signed_in_user

  def new
    @order=Order.new
  end

end
