class Session < ActiveRecord::Base
  belongs_to :user, inverse_of: :sessions

  validates :user, presence: true
  validates :remember_token, presence: true
  validates :ip_addr, presence: true

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

end
