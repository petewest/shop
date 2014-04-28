class PostageServicesController < ApplicationController
  before_action :signed_in_seller
  before_action :find_postage_service, only: [:edit, :update]

  def index
    @postage_services=PostageService.all
  end

  def new
    @postage_service=PostageService.new
  end

  def create
    @postage_service=PostageService.new(postage_service_params)
    if  @postage_service.save
      flash.now[:success]="Postage service created"
      respond_to do |format|
        format.html { flash.keep and redirect_to postage_services_path }
        format.js
      end
    else
      flash.now[:danger]="Postage service creation failed"
      render 'new'
    end
  end

  def edit
    
  end

  def update
    if @postage_service.update_attributes(postage_service_params)
      flash.now[:success]="Item updated"
      respond_to do |format|
        format.html { flash.keep and redirect_to postage_services_path }
        format.js
      end
    else
      flash.now[:danger]="Update failed"
      render 'edit'
    end
  end

  private
    def postage_service_params
      params.require(:postage_service).permit(:name, :default)
    end

    def find_postage_service
      @postage_service=PostageService.find(params[:id]) if params[:id]
    end
end
