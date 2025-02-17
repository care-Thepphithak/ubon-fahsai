class Report < ApplicationRecord
  has_many_attached :images

  TAGS = [ "ไฟป่า", "เผาไร่อ้อย", "เผานาข้าว", "เผาไร่อื่นๆ", "ไฟไหม้บ้าน", "ไฟไหม้รถ", "ไฟไหม้โรงงาน", "เผาขยะ" ].freeze

  SEVERITY_LEVELS = {
    "เล็กน้อย" => (1..20),
    "ปานกลาง" => (21..40),
    "รุนแรง" => (41..60),
    "รุนแรงมาก" => (61..80),
    "วิกฤติ" => (81..100)
  }.freeze

  validate :tags_must_be_valid
  validates :description, length: { maximum: 300 }
  validates :severity_level, inclusion: { in: SEVERITY_LEVELS.keys }

  private

  def tags_must_be_valid
    tags_array = if tags.is_a?(Array)
      tags
    elsif tags.present?
      JSON.parse(tags) rescue []
    else
      []
    end

    if tags_array.any? { |tag| !TAGS.include?(tag) }
      errors.add(:tags, "มีค่าไม่ถูกต้อง")
    end
  end
end
