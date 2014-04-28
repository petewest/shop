class PostageServicesController < ApplicationController
  before_action :signed_in_seller

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


  private
    def postage_service_params
      params.require(:postage_service).permit(:name, :default)
    end
end
