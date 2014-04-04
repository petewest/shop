class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout :check_modal

  include SessionsHelper
  include CartHelper

  private
    def check_modal
      params[:modal] ? 'modal' : 'application'
    end
end
