class GiftCardsController < ApplicationController
  before_action :signed_in_user
  before_action :find_gift_card

  def index
    @gift_cards=current_user.gift_cards_redeemed
  end

  def find
    
  end

  def allocate
    @gift_card.present? and @gift_card.with_lock do
      @gift_card.redeemer=current_user
      if @gift_card.save
        flash[:success]=I18n.t('gift_cards.allocate.success')
        redirect_to gift_cards_path
      else
        flash.now[:danger]=I18n.t('gift_cards.allocate.failure')
        render 'find'
      end
    end
  end

  private
    def find_gift_card
      @gift_card=GiftCard.redeemable.find_by_encoded_token!(params[:id]) if params[:id]
    rescue ActiveSupport::MessageVerifier::InvalidSignature => e
      @gift_card=nil
      flash[:warning]=I18n.t('gift_cards.missing')
      render 'find'
    rescue ActiveRecord::RecordNotFound => e
      @gift_card=nil
      flash[:warning]=I18n.t('gift_cards.already_redeemed')
      render 'find'
    end
end
