class Report < ApplicationRecord
  include ActionView::Helpers::DateHelper

  has_many_attached :images

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

  def self.count_today
    where(created_at: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day).count
  end

  def self.count_yesterday
    where(created_at: Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day).count
  end

  def self.count_harmful_today
    where(severity_level: [ "วิกฤติ", "รุนแรงมาก" ], created_at: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day).count
  end

  def self.count_harmful_yesterday
    where(severity_level: [ "วิกฤติ", "รุนแรงมาก" ], created_at: Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day).count
  end

  def self.count_harmful_reports
    where(severity_level: [ "วิกฤติ", "รุนแรงมาก" ]).count
  end

  def self.top_districts
    select("split_part(reverse(split_part(reverse(location_name), 'จังหวัด', 1)), ' ', -2) AS district, COUNT(*) AS district_count")
      .where("location_name LIKE ?", "%จังหวัด%")
      .where("created_at >= ?", Date.today.beginning_of_day)
      .group("district")
      .order(Arel.sql("district_count DESC"))
  end

  def self.severity_label(value)
    SEVERITY_LEVELS.find { |_label, range| range.cover?(value.to_i) }&.first || SEVERITIES.last
  end

  def self.severity_levels_json
    SEVERITY_LEVELS.transform_values(&:max).to_json
  end

  def as_json(options = {})
    super(options).merge(
      severity_color: severity_color,
      images_urls: images_urls,
      time_ago_message: time_ago_in_words(created_at, datetime: :distance_in_words, locale: :th) + " ที่แล้ว",
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
  validate :latlong_must_be_within_user_areas
  validates :lat, presence: { message: "ไม่พบข้อมูลละติจูด" }
  validates :long, presence: { message: "ไม่พบข้อมูลลองจิจูด" }
  validates :location_name, presence: { message: "ไม่พบข้อมูลชื่อสถานที่" }

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
    host = Rails.env.development? ? "localhost:3000" : "ubon-fahsai-dev.odd.works"
    protocol = Rails.env.development? ? "http" : "https"

    images.attached? ? images.map { |image| Rails.application.routes.url_helpers.minio_proxy_url(image.blob.key, protocol: protocol, host: host) } : []
  end

  def latlong_must_be_within_user_areas
    return unless user.areas.present?

    user_areas = user.areas.map(&:coordinates)
    user_areas = user_areas.map { |area| area.map { |coordinate| coordinate.to_fs } }

    if user_areas.none? { |area| point_in_polygon?([ lat.to_f, long.to_f ], area) }
      errors.add(:base, "ตำแหน่งนี้ไม่ได้อยู่ในพื้นที่ที่รับผิดชอบ")
    end
  end

  def point_in_polygon?(point, polygon)
    x, y = point
    inside = false

    parsed_polygon = polygon.map do |coord_string|
      coords = coord_string.gsub(/[\[\]]/, "").split(",").map(&:to_f)
      coords
    end

    j = parsed_polygon.size - 1
    (0...parsed_polygon.size).each do |i|
      xi, yi = parsed_polygon[i]
      xj, yj = parsed_polygon[j]

      intersect = ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi)
      inside = !inside if intersect

      j = i
    end

    inside
  end
end
