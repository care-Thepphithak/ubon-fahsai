class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  scope :admin, -> { admin == true }

  has_many :user_areas
  has_many :areas, through: :user_areas

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
