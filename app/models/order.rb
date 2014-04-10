class Order < ActiveRecord::Base
  belongs_to :user, inverse_of: :orders
  has_many :line_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :line_items, inverse_of: :orders

  #For anything not in "cart" status
  #So all validations that make sure it's an order instead of a shopping cart
  with_options if:  -> { status and status!="cart" } do |non_cart|
    non_cart.validates :user, presence: true
    non_cart.validates :line_items, presence: {message: "can't process blank order"}
    non_cart.validates :delivery_address, presence: true
    non_cart.validates :billing_address, presence: true
  end

  #When switching to "placed" status we want to run some extra
  #process to check stock for validation, then allocate stock after successful save
  with_options if: -> { status_changed? and status=="placed" } do |placed|
    placed.validate :stock_check
    placed.after_save :decrement_stock
  end

  accepts_nested_attributes_for :line_items, allow_destroy: true

  enum status: {cart: 0, checkout: 10, placed: 20, paid: 30, dispatched: 40, cancelled: 100}

  before_create -> {self.status||=:cart}

  before_save :pre_save

  default_scope -> {includes(line_items: [:product, :currency])}

  def costs
    line_items.group_by(&:currency).map do |currency, items|
      Hash(currency: currency, cost: items.map(&:cost).sum)
    end if line_items.any?
  end

  def self.pending
    where(status: [self.statuses[:placed], self.statuses[:paid]])
  end


  private 
    def pre_save
      self.type=((status=="cart") ? "Cart" : nil) if status_changed?
      true
    end

    def stock_check
      errors[:base]<<"Not enough stock" if !line_items.all?(&:stock_check)
    end

    def decrement_stock
      line_items.all?(&:take_stock)
    end
end
