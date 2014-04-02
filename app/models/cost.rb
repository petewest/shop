class Cost < ActiveRecord::Base
  belongs_to :costable, polymorphic: true
  belongs_to :currency

  validates :costable, presence: true
  validates :currency, presence: true
  validates :value, presence: true, numericality: {only_integer: true}
end
