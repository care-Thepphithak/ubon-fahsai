class Report < ApplicationRecord
  include ActionView::Helpers::DateHelper

  TAGS = %w[ไฟป่า เผาไร่อ้อย เผานาข้าว เผาไร่อื่นๆ ไฟไหม้บ้าน ไฟไหม้รถ ไฟไหม้โรงงาน เผาขยะ].freeze
  SEVERITY_MAPPING = {
    "เล็กน้อย" => "#FE965F",
    "ลุกลาม" => "#FF7744",
    "เฝ้าระวัง" => "#FFA500",
    "ปานกลาง" => "#FF6E37",
    "รุนแรง" => "#FF6159",
    "รุนแรงมาก" => "#FF443A",
    "วิกฤติ" => "#FF392F"
  }.freeze
  SEVERITIES = SEVERITY_MAPPING.keys.freeze
  MAX_SEVERITY = 100
  SEVERITY_LEVEL_RANGES = -> {
    step = MAX_SEVERITY / SEVERITIES.size
    SEVERITIES.each_with_index.map do |label, i|
      [ label, ((i * step) + 1)..((i + 1) * step) ]
    end.to_h.freeze
  }.call.freeze

  after_create :broadcast_report

  has_many_attached :images
  has_many :area_reports, dependent: :destroy
  has_many :areas, through: :area_reports

  scope :today, -> { where(created_at: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day) }
  scope :yesterday, -> { where(created_at: Time.zone.yesterday.beginning_of_day..Time.zone.yesterday.end_of_day) }
  scope :harmful, -> { where(severity_level: [ "วิกฤติ", "รุนแรงมาก" ]) }

  validate :tags_must_be_valid
  validate :location_within_responsible_areas?
  validates :description, length: { maximum: 300 }
  validates :severity_level, inclusion: { in: SEVERITY_LEVEL_RANGES.keys }
  validates :lat, presence: { message: "ไม่พบข้อมูลละติจูด" }
  validates :long, presence: { message: "ไม่พบข้อมูลลองจิจูด" }
  validates :location_name, presence: { message: "ไม่พบข้อมูลชื่อสถานที่" }

  def self.top_districts_today
    joins(:areas)
      .select("areas.name as district, areas.coordinates as coordinates, COUNT(*) AS district_count")
      .where("reports.created_at >= ?", Time.zone.today.beginning_of_day)
      .group("areas.name, areas.coordinates")
      .order(Arel.sql("district_count DESC"))
  end

  def self.severity_levels_json
    SEVERITY_LEVEL_RANGES.transform_values(&:max).to_json
  end

  def as_json(options = {})
    super(options).merge(
      severity_color: severity_color,
      image_urls: generated_image_urls,
      time_ago_message: time_ago_in_words(created_at, datetime: :distance_in_words, locale: :th) + " ที่แล้ว",
    )
  end

  def severity_color
    SEVERITY_MAPPING[severity_level] || "#808080"
  end

  private

  def tags_must_be_valid
    tags_array = parse_tags(tags)

    if invalid_tags?(tags_array)
      errors.add(:tags, "มีค่าไม่ถูกต้อง")
    end
  end

  def parse_tags(tags)
    return tags if tags.is_a?(Array)
    return JSON.parse(tags) rescue [] if tags.present?
    []
  end

  def invalid_tags?(tags_array)
    tags_array.any? { |tag| !TAGS.include?(tag) }
  end

  def generated_image_urls
    return [] unless images.attached?

    host = Rails.env.development? ? "localhost:3000" : "ubon-fahsai-dev.odd.works"
    protocol = Rails.env.development? ? "http" : "https"

    images.map do |image|
      Rails.application.routes.url_helpers.minio_proxy_url(image.blob.key, protocol: protocol, host: host)
    end
  end

  def location_within_responsible_areas?
    return unless Current.user.areas.present?
    return if in_polygon?

    errors.add(:base, "ตำแหน่งนี้ไม่ได้อยู่ในพื้นที่ที่รับผิดชอบ")
  end

  def in_polygon?
    report_location = [ lat.to_f, long.to_f ]
    parsed_user_areas = parse_user_areas

    parsed_user_areas.any? { |area| point_in_polygon?(report_location, area) }
  end

  def parse_user_areas
    Current.user.areas.map(&:coordinates).map do |area|
      area.map { |coordinate| coordinate.to_fs }
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

  def broadcast_report
    ActionCable.server.broadcast("report_channel", {
      message: self,
      total_count: Report.today.count,
      harmful_count: Report.today.harmful.count,
      top_districts: Report.top_districts_today.map { |report| { district: report.district, district_count: report.district_count } }
    })
  end
end
