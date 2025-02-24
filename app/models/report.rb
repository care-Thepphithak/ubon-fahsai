class Report < ApplicationRecord
  include ActionView::Helpers::DateHelper

  has_many_attached :images

  def self.count_today
    where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).count
  end

  def self.count_yesterday
    where(created_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day).count
  end

  def self.count_harmful_today
    where(severity_level: "วิกฤติ", created_at: Date.today.beginning_of_day..Date.today.end_of_day).count
  end

  def self.count_harmful_yesterday
    where(severity_level: "วิกฤติ", created_at: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day).count
  end

  def as_json(options = {})
    super(options).merge(
      severity_color: severity_color,
      images_urls: images_urls,
      time_ago_message: time_ago_in_words(created_at, datetime: :distance_in_words, locale: :th) + " ที่แล้ว"
    )
  end

  TAGS = %w[ไฟป่า เผาไร่อ้อย เผานาข้าว เผาไร่อื่นๆ ไฟไหม้บ้าน ไฟไหม้รถ ไฟไหม้โรงงาน เผาขยะ].freeze

  MAX_SEVERITY = 100
  SEVERITIES = %w[เล็กน้อย ลุกลาม เฝ้าระวัง ปานกลาง รุนแรง รุนแรงมาก วิกฤติ].freeze
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

  def severity_color
    case severity_level
    when "เล็กน้อย" then "#FE965F"
    when "ลุกลาม" then "#FF7744"
    when "เฝ้าระวัง" then "#FFA500"
    when "ปานกลาง" then "#FF6E37"
    when "รุนแรง" then "#FF6159"
    when "รุนแรงมาก" then "#FF443A"
    when "วิกฤติ" then "#FF392F"
    else "#808080"
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

  def images_urls
    images.attached? ? images.map { |img| Rails.application.routes.url_helpers.rails_blob_url(img, only_path: true) } : []
  end
end
