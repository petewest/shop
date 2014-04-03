class Order < ActiveRecord::Base
  belongs_to :user, inverse_of: :orders
  has_many :line_items, inverse_of: :order
  has_many :products, through: :line_items, inverse_of: :orders

  
  validates :user, presence: true, if:  -> { status and status!="cart" }
  accepts_nested_attributes_for :line_items, allow_destroy: true

  enum status: [:cart, :placed, :paid, :dispatched, :cancelled]

  before_save {self.status||=:cart}

  before_save :check_type

  def costs
    line_items.map(&:cost).group_by(&:currency_id).map do |currency_id, items|
      Cost.new(currency_id: currency_id, value: items.map(&:value).sum)
    end if line_items.any?
  end

  def self.pending
    where(status: [self.statuses[:placed], self.statuses[:paid]])
  end


  private 
    def check_type
      self.type=((status=="cart") ? "Cart" : nil) if status_changed?
    end
end
