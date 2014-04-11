class StockLevel < ActiveRecord::Base
  belongs_to :product

  has_many :allocations, inverse_of: :stock_level

  validates :product, presence: true
  validates :due_at, presence: true
  validates :start_quantity, presence: true, numericality: {only_integer: true}
  validates :current_quantity, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: :start_quantity}, allow_nil: true

  before_save -> { self.current_quantity||=start_quantity }

  def self.current
    where(
      arel_table[:due_at].lt(DateTime.now).or(arel_table[:allow_preorder].eq(true))
    ).where(
      arel_table[:current_quantity].gt(0)
    ).where(
      arel_table[:expires_at].gt(DateTime.now).or(arel_table[:expires_at].eq(nil))
    )
  end

  def self.available
    current.map(&:current_quantity).sum
  end

end
