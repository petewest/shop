class PostageCostsController < ApplicationController
  before_action :signed_in_seller
  before_action :postage_cost_from_params, only: [:edit, :update, :destroy]

  def index
    @postage_costs=PostageCost.order(from_weight: :asc).all
  end

  def edit
  end

  def update
    if @postage_cost.update_attributes(postage_params)
      flash.now[:success]="Postage cost updated"
      respond_to do |format|
        format.html {flash.keep and redirect_to postage_services_url}
        format.js
      end
    else
      flash.now[:danger]="Postage cost update failed"
      render 'edit'
    end
  end

  def new
    @postage_cost=PostageCost.new
    @postage_cost.postage_service=PostageService.find(params[:postage_service_id]) if params[:postage_service_id]
  end

  def create
    @postage_cost=PostageCost.new(postage_params)
    if @postage_cost.save
      flash.now[:success]="Postage cost created"
      respond_to do |format|
        format.html { flash.keep and redirect_to postage_services_url }
        format.js
      end
    else
      flash.now[:danger]="Postage cost creation failed"
      render 'new'
    end
  end

  def destroy
    if @postage_cost.destroy
      flash.now[:success]="Postage cost deleted"
    else
      flash.now[:danger]="Postage cost deletion failed"
    end
    respond_to do |format|
      format.html { flash.keep and redirect_to postage_services_url }
      format.js
    end
  end

  private
    def postage_cost_from_params
      @postage_cost=PostageCost.find(params[:id])
    end

    def postage_params
      params.require(:postage_cost).permit(:postage_service_id, :from_weight, :to_weight, :unit_cost, :currency_id)
    end
end
