class GiftCard < ActiveRecord::Base
  ## Relationships
  belongs_to :buyer, class_name: "User", inverse_of: :gift_cards_bought
  belongs_to :redeemer, class_name: "User", inverse_of: :gift_cards_redeemed
  
  ## Validations
  validates :buyer, presence: true
  validates :start_value, presence: true, numericality: {greater_than: 0}
  # Allow nil's here because it won't get set until the first save
  validates :current_value, allow_nil: true, numericality: {greater_than_or_equal_to: 0}
  # But disallow if the record has already been saved to the DB
  validates :current_value, presence: true, if: -> { persisted? }
  validate :current_less_than_start
  validates :token, presence: true
  

  ## Callbacks
  after_initialize -> { self.token||=SecureRandom.urlsafe_base64 }
  before_save -> { self.current_value||=start_value }

  ## Class methods for encoding and decoding the token


  private
    def current_less_than_start
      errors[:current_value]="can't be greater than start value" if current_value and current_value>start_value
    end
end
