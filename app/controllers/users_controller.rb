class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :password, :update_password]
  before_action :get_user, only: [:edit, :update, :password, :update_password]

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

  def password
  end

  def update_password
    password_params=seller_password_params if @user.is_a?(Seller)
    password_params||=user_password_params
    if !@user.authenticate(password_params[:old_password])
      flash[:warning]="Old password does not match"
      render 'password'
      return
    end
    # Force password digest to be nil so that it re-checks for blank password
    @user.password=nil
    if @user.update_attributes(password_params.except(:old_password))
      flash[:success]="Password changed"
      redirect_to root_url
    else
      flash.now[:danger]="Password change failed"
      render 'password'
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
    def user_password_params
      params.require(:user).permit(:password, :password_confirmation, :old_password)
    end
    def seller_password_params
      params.require(:user).permit(:password, :password_confirmation, :old_password)
    end
    def get_user
      @user=current_user
    end
end
