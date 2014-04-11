class Address < ActiveRecord::Base
  belongs_to :user, inverse_of: :addresses

  validates :user, presence: true
  validates :address, presence: true
  validates :label, presence: true, uniqueness: {scope: :user}

  validates :default_billing, uniqueness: {scope: :user}, if: -> { default_billing? }
  validates :default_delivery, uniqueness: {scope: :user}, if: -> { default_delivery? }

  has_many :order_addresses, foreign_key: "source_address_id", dependent: :nullify
  
  scope :billing, -> { where(default_billing: true) }
  scope :delivery, -> { where(default_delivery: true) }
end
