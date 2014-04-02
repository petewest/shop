class Cost < ActiveRecord::Base
  belongs_to :costable, polymorphic: true, inverse_of: :cost
  belongs_to :currency

  validates :costable_id, presence: true, uniqueness: {scope: :costable_type}
  validates :currency, presence: true
  validates :value, presence: true, numericality: {only_integer: true}
end
