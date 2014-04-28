class PostageService < ActiveRecord::Base
  ## Relationships
  has_many :postage_costs, dependent: :destroy
  has_many :orders, dependent: :nullify

  ## Validations
  validates :name, presence: true, uniqueness: true

  ## Scopes
  scope :default, -> { where(default: true).first }

  #callbacks
  before_save :clear_defaults, if: -> { default? }


  private
    def clear_defaults
      #if we're setting this item to be default
      #we want to clear the flag from any other items
      defaults=self.class.where(default: true)
      defaults=defaults.where.not(id: id) if persisted?
      defaults.update_all(default: false)
    end
end
