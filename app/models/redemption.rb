class Redemption < ActiveRecord::Base
  ## Relationships
  belongs_to :order
  belongs_to :gift_card
  belongs_to :currency

  ## Validations
  validates :order, presence: true
  validates :gift_card, presence: true
  validate :order_and_gift_card_currencies

  ## Callbacks
  before_save :decrement_gift_card_balance



  private
    def decrement_gift_card_balance
      # Grab a lock on the card so that someone can't try and use a gift_card twice while we're still processing the last one
      gift_card.with_lock do
        self.value=[gift_card.current_value, order.cost].min
        gift_card.current_value-=value
        gift_card.save!
      end
    end
end
