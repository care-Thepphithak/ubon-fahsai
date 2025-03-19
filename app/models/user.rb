class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :user_areas
  has_many :areas, through: :user_areas

  scope :admin, -> { admin == true }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
