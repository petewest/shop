class StockLevel < ActiveRecord::Base
  belongs_to :product

  has_many :allocations, inverse_of: :stock_level
  has_many :line_items, through: :allocations
  has_many :orders, through: :line_items

  validates :product, presence: true
  validates :due_at, presence: true
  validates :start_quantity, presence: true, numericality: {only_integer: true}
  validates :current_quantity, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: :start_quantity}, allow_nil: true

  before_save -> { self.current_quantity||=start_quantity }
  before_destroy :check_allocations

  def self.current
    where(
      arel_table[:due_at].lt(DateTime.now).or(arel_table[:allow_preorder].eq(true))
    ).where(
      arel_table[:current_quantity].gt(0)
    ).where(
      arel_table[:expires_at].gt(DateTime.now).or(arel_table[:expires_at].eq(nil))
    ).order(due_at: :asc)
  end

  def self.available
    current.sum(:current_quantity)
  end


  private
    def check_allocations
      errors[:base]<<"Cannot be removed while allocated to orders" and raise ActiveRecord::Rollback if allocations.any?
    end

end
