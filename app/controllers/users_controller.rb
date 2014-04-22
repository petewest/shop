class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit]
  def new
    @user=User.new
  end

  def create
    @user=User.new(user_params)
    if @user.save
      flash[:success]="Welcome #{@user.name}"
      sign_in @user
      redirect_to root_path
    else
      flash.now[:danger]="New user creation failed"
      render 'new'
    end
  end

  def edit
  end


  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
