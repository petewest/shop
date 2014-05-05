class Redemption < ActiveRecord::Base
  ## Relationships
  belongs_to :order
  belongs_to :gift_card
  belongs_to :currency

  ## Validations
  validates :order, presence: true
  validates :gift_card, presence: true
  with_options if: -> {order and gift_card} do |present|
    present.validate :order_and_gift_card_currencies
    present.validate :order_and_gift_card_users
  end

  ## Callbacks
  before_save :take_balance_from_gift_card
  # We won't allow any updates.  Once it's set, it's set.
  before_update -> { raise ActiveRecord::Rollback }
  # Destroying this object credits the gift card
  before_destroy :credit_balance_to_gift_card



  private
    def take_balance_from_gift_card
      # Grab a lock on the card so that someone can't try and use a gift_card twice while we're still processing the last one
      order.with_lock do
        gift_card.with_lock do
          self.currency=gift_card.currency
          self.value=[gift_card.current_value, order.cost].min
          gift_card.current_value-=value
          order.gift_card_value+=value
          raise ActiveRecord::Rollback unless gift_card.save and order.save
        end
      end
    end

    def credit_balance_to_gift_card
      order.with_lock do
        gift_card.with_lock do
          gift_card.current_value+=value
          order.gift_card_value-=value
          raise ActiveRecord::Rollback unless gift_card.save and order.save
        end
      end
    end

    def order_and_gift_card_currencies
      errors[:base]<<"order currency and gift card currency must match" if order.currency!=gift_card.currency
    end

    def order_and_gift_card_users
      errors[:base]<<"redeem gift card before using it" if order.user!=gift_card.redeemer 
    end
end
