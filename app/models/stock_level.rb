class StockLevel < ActiveRecord::Base
  belongs_to :product

  validates :product, presence: true
  validates :due_at, presence: true
  validates :start_quantity, presence: true, numericality: {only_integer: true}
  validates :current_quantity, numericality: {only_integer: true, greater_than_or_equal_to: 0}, allow_nil: true

  validate :current_lte_start

  before_save -> { self.current_quantity||=start_quantity }

  def self.current
    where(
      arel_table[:due_at].lt(DateTime.now)
    ).where(
      arel_table[:current_quantity].gt(0)
    ).where(
      arel_table[:expires_at].gt(DateTime.now).or(arel_table[:expires_at].eq(nil))
    )
  end

  private
    def current_lte_start
      errors.add(:current_quantity, "must be less than or equal to start quantity") if current_quantity and current_quantity>start_quantity
    end

end
