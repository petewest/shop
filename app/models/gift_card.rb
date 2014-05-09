class GiftCard < ActiveRecord::Base
  include Costable

  ## Callbacks
  after_initialize -> { self.token||=SecureRandom.urlsafe_base64; self.current_value||=0; self.start_value||=0; }
  # Prepare the item to save
  before_save :prep_for_save

  ## Relationships
  belongs_to :buyer, class_name: "User", inverse_of: :gift_cards_bought
  belongs_to :redeemer, class_name: "User", inverse_of: :gift_cards_redeemed
  belongs_to :allocation, class_name: "GiftCardAllocation"
  has_many :redemptions, inverse_of: :gift_cards
  has_many :orders, through: :redemptions
  
  ## Validations
  validates :buyer, presence: true
  validates :currency, presence: true
  validates :start_value, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :current_value, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :token, presence: true

  ## Scopes
  scope :in_credit, -> { where(arel_table[:current_value].gt(0)) }
  scope :redeemable, -> { where(redeemer: nil) }

  ## Methods

  # unit_cost virtual methods for for accessing start_value from costable
  # this is start_value as that's what the costable partial sets
  alias_attribute :unit_cost, :start_value

  # Give the encoded version of the token
  def encoded_token
    Rails.application.message_verifier(:gift_card).generate(token)
  end

  # Our display name
  def name
    self.class.model_name.human + " #{ActiveSupport::NumberHelper::NumberToCurrencyConverter.convert(current_value/(10.0**currency.decimal_places), unit: currency.symbol)}"
  end

  ## Class method for decoding the token and finding the corresponding gift card
  # raises ActiveSupport::MessageVerifier::InvalidSignature if the token isn't valid
  def self.find_by_encoded_token!(encoded_token)
    search_token=Rails.application.message_verifier(:gift_card).verify(encoded_token)
    find_by!(token: search_token)
  end


  private
    def prep_for_save 
      # Set current value to be the difference in the start value
      self.current_value-=start_value_was.to_i-start_value
      # as we've made changes to current_value, we'll re-run our validations on it
      validate_current_value
    end

    def validate_current_value
      errors[:current_value]="can't be greater than start value" and return false if current_value>start_value
      errors[:current_value]="must be greater than or equal to zero" and return false if current_value<0
    end
end
