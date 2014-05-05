class GiftCard < ActiveRecord::Base
  ## Relationships
  belongs_to :buyer, class_name: "User", inverse_of: :gift_cards_bought
  belongs_to :redeemer, class_name: "User", inverse_of: :gift_cards_redeemed
  belongs_to :currency
  
  ## Validations
  validates :buyer, presence: true
  validates :currency, presence: true
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

  # Give the encoded version of the token
  def encoded_token
    Rails.application.message_verifier(:gift_card).generate(token)
  end

  ## Class method for decoding the token and finding the corresponding gift card
  # raises ActiveSupport::MessageVerifier::InvalidSignature if the token isn't valid
  def self.find_by_encoded_token(encoded_token)
    search_token=Rails.application.message_verifier(:gift_card).verify(encoded_token)
    find_by_token(search_token)
  end


  private
    def current_less_than_start
      errors[:current_value]="can't be greater than start value" if current_value and current_value>start_value
    end
end
