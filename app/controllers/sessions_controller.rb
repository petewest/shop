class SessionsController < ApplicationController
  before_action :signed_in_user, only: [:destroy]

  def new
  end

  def create
    user=User.find_by_email(params[:session][:email])
    if user and user.authenticate(params[:session][:password])
      sign_in user, (params[:session][:remember].to_i==1)
      flash[:success]="Welcome back, #{user.name}"
      redirect_back_or root_url
    else
      flash.now[:danger]="Incorrect login"
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

end
