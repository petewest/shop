class PostageServicesController < ApplicationController
  before_action :signed_in_seller

  def index
    @postage_services=PostageService.all
  end
end
