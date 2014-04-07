class StockLevel < ActiveRecord::Base
  belongs_to :product

  validates :product, presence: true
  validates :due_at, presence: true

  def self.current
    where(
      arel_table[:due_at].lt(DateTime.now)
    ).where(
      arel_table[:current_quantity].gt(0)
    ).where(
      arel_table[:expires_at].gt(DateTime.now).or(arel_table[:expires_at].eq(nil))
    )
  end
end
