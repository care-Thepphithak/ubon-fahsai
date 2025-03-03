class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :user_areas
  has_many :areas, through: :user_areas

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def admin?
    admin == true
  end
end
