class RedemptionsController < ApplicationController
  before_action :signed_in_user

  def create
    @order=current_user.orders.find(params[:order_id]) if params[:order_id]
    @redemption=@order.redemptions.new(redemption_params)
    if @redemption.save
      flash.now[:success]=I18n.t('redemptions.create.success')
    else
      flash.now[:danger]=I18n.t('redemptions.create.failure')
    end
    respond_to do |format|
      format.html { flash.keep and redirect_to pay_order_path(@order) }
      format.js
    end
  end

  private
    def redemption_params
      params.require(:redemption).permit(:gift_card_id)
    end
end
