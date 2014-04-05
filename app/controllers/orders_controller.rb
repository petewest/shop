class OrdersController < ApplicationController
  before_action :signed_in_user

  def index
    @orders=current_user.orders.includes(line_items: [:product]).all
  end
end
