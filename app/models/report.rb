class Report < ApplicationRecord
  has_many_attached :images

  TAGS = %w[ไฟป่า เผาไร่อ้อย เผานาข้าว เผาไร่อื่นๆ ไฟไหม้บ้าน ไฟไหม้รถ ไฟไหม้โรงงาน เผาขยะ].freeze

  MAX_SEVERITY = 100
  SEVERITIES = %w[เล็กน้อย ควบคุมได้ เฝ้าระวัง ปานกลาง รุนแรง รุนแรงมาก วิกฤติ].freeze
  SEVERITY_LEVELS = begin
    step = MAX_SEVERITY / SEVERITIES.size
    SEVERITIES.each_with_index.map { |label, i| [ label, (i * step + 1)..((i + 1) * step) ] }.to_h.freeze
  end

  validate :tags_must_be_valid
  validates :description, length: { maximum: 300 }
  validates :severity_level, inclusion: { in: SEVERITY_LEVELS.keys }

  class << self
    def severity_label(value)
      SEVERITY_LEVELS.find { |_label, range| range.cover?(value.to_i) }&.first || SEVERITIES.last
    end

    def severity_levels_json
      SEVERITY_LEVELS.transform_values(&:max).to_json
    end
  end

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
