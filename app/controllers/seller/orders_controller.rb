class Seller::OrdersController < ApplicationController
  before_action :signed_in_seller
  def index
    @orders=Order
    @orders=StockLevel.find(params[:stock_level_id]).orders if params[:stock_level_id]
    @orders=@orders.all
  end
end
