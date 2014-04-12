class PostageCostsController < ApplicationController
  before_action :signed_in_seller
  before_action :postage_cost_from_params, only: [:edit, :update]

  def index
    @postage_costs=PostageCost.all
  end

  def edit
  end

  def update
    if @postage_cost.update_attributes(postage_params)
      flash[:success]="Postage cost updated"
      redirect_to postage_costs_url
    else
      flash[:danger]="Postage cost update failed"
      render 'edit'
    end
  end

  def new
    @postage_cost=PostageCost.new
  end

  private
    def postage_cost_from_params
      @postage_cost=PostageCost.find(params[:id])
    end

    def postage_params
      params.require(:postage_cost).permit(:from_weight, :to_weight, :unit_cost, :currency_id)
    end
end
