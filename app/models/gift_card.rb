class GiftCard < ActiveRecord::Base
  include Costable
  ## Relationships
  belongs_to :buyer, class_name: "User", inverse_of: :gift_cards_bought
  belongs_to :redeemer, class_name: "User", inverse_of: :gift_cards_redeemed
  has_many :redemptions, inverse_of: :gift_cards
  has_many :orders, through: :redemptions
  
  ## Validations
  validates :buyer, presence: true
  validates :currency, presence: true
  validates :start_value, presence: true, numericality: {only_integer: true, greater_than: 0}
  # Allow nil's here because it won't get set until the first save
  validates :current_value, allow_nil: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  # But disallow if the record has already been saved to the DB
  validates :current_value, presence: true, if: -> { persisted? }
  validate :current_less_than_start
  validates :token, presence: true

  ## Scopes
  scope :in_credit, -> { where(arel_table[:current_value].gt(0)) }

  ## Callbacks
  after_initialize -> { self.token||=SecureRandom.urlsafe_base64 }
  before_save -> { self.current_value||=start_value }

  ## Methods

  # Decimal value methods to for the user to populate
  def decimal_value
    start_value / (10.0**currency.decimal_places) if currency
  end

  def decimal_value=(new_value)
    self.start_value=(new_value*(10.0**currency.decimal_places)).floor if currency
  end

  # Give the encoded version of the token
  def encoded_token
    Rails.application.message_verifier(:gift_card).generate(token)
  end


  ## Methods that help this model behave like a buyable item

  # Unit cost is the start value
  def unit_cost
    start_value
  end

  # There's no concept of stock for gift cards, so we'll just return true
  def stock_check
    true
  end

  def allocate_stock_to(line_item)
    true
  end

  # There's also no weight
  def weight
    0
  end

  # Dummy name
  def name
    "Gift card"
  end

  # Will have to respond to stock_levels
  def stock_levels
    
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
