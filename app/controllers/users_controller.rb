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
    params_to_use=seller_edit_params if @user.is_a? Seller
    params_to_use||=user_edit_params
    if @user.update_attributes(params_to_use)
      flash[:success]="User details updated"
      redirect_to root_url
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
    def seller_edit_params
      params.require(:seller).permit(:name, :email, :bcc_on_email)
    end
    def get_user
      @user=current_user
    end
end
