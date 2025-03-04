class Area < ApplicationRecord
  has_many :user_areas, dependent: :destroy
  has_many :users, through: :user_areas

  before_validation :strip_whitespace

  validates :name, presence: { message: "โปรดระบุชื่อพื้นที่" }
  validates :name, uniqueness: { message: "ชื่อพื้นที่นี้มีอยู่แล้ว", case_sensitive: false }

  private

  def strip_whitespace
    self.name = name.strip if name.present?
  end
end
