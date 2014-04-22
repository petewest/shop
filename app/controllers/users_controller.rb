class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update]
  before_action :get_user, only: [:edit, :update]

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

  def update
    if @user.update_attributes(user_edit_params)
      flash[:success]="User details updated"
      redirect_to my_account_url
    else
      flash.now[:danger]="Update failed"
      render 'edit'
    end
  end


  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    def user_edit_params
      params.require(:user).permit(:name, :email)
    end
    def get_user
      @user=current_user
    end
end
