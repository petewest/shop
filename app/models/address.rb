class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  validates :addressable, presence: true
  validates :address, presence: true
  validates :label, presence: true, uniqueness: {scope: :addressable}

  validates :default_billing, uniqueness: {scope: :addressable}, if: -> { default_billing? }
  validates :default_delivery, uniqueness: {scope: :addressable}, if: -> { default_delivery? }

  scope :billing, -> { where(default_billing: true) }
  scope :delivery, -> { where(default_delivery: true) }
end
