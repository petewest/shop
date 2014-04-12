class PostageCostsController < ApplicationController
  before_action :signed_in_seller
  before_action :postage_cost_from_params, only: [:edit]

  def index
    @postage_costs=PostageCost.all
  end

  def edit
  end

  private
    def postage_cost_from_params
      @postage_cost=PostageCost.find(params[:id])
    end
end
