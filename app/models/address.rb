class Address < ActiveRecord::Base
  belongs_to :user, inverse_of: :addresses

  validates :user, presence: true
  validates :address, presence: true
  validates :label, presence: true

  validates :default_billing, uniqueness: {scope: :user}, if: -> { default_billing? }
  validates :default_delivery, uniqueness: {scope: :user}, if: -> { default_delivery? }

  scope :billing, -> { where(default_billing: true) }
  scope :delivery, -> { where(default_delivery: true) }
end
