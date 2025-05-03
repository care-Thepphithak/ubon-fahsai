require 'rails_helper'

RSpec.describe Report, type: :model do
  let(:user) { create(:user) }
  let(:area) { create(:area) }
  let(:report) { create(:report) }

  before do
    allow(Current).to receive(:user).and_return(user)
    area_coordinates = JSON.parse(area.coordinates)
    allow(area).to receive(:coordinates).and_return(area_coordinates)
    create(:area_report, area: area, report: report)
    user.areas << area
  end

  describe 'top_districts_today' do
    it 'returns the districts with the correct report counts for today' do
      result = Report.top_districts_today
      expect(result.first.district).to eq("Test Area Unit")
    end

    it 'does not include reports created outside of today' do
      result = Report.top_districts_today
      expect(result.map(&:district_count).sum).to eq(1)
    end
  end

  describe 'severity_levels_json' do
    describe 'SEVERITY_LEVEL_RANGES' do
      it 'returns the correct maximum severity levels for each severity' do
        expected_result = {
          "เล็กน้อย" => 14,
          "ลุกลาม" => 28,
          "เฝ้าระวัง" => 42,
          "ปานกลาง" => 56,
          "รุนแรง" => 70,
          "รุนแรงมาก" => 84,
          "วิกฤติ" => 98
        }.to_json

        result = Report::SEVERITY_LEVEL_RANGES.transform_values(&:max).to_json

        expect(result).to eq(expected_result)
      end
    end
  end

  describe 'as_json' do
    let(:report) { create(:report, severity_level: "รุนแรง", created_at: 2.hours.ago) }

    before do
      report.images.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test.jpg')),
        filename: 'test.jpg',
        content_type: 'image/jpg'
      )
    end

    it 'returns the correct JSON representation of the report' do
      json = report.as_json

      expect(json[:severity_color]).to eq("#FF6159")
      expect(json[:image_urls]).to be_an(Array)
      expect(json[:image_urls].first).to include("http")
      expect(json[:time_ago_message]).to include("ที่แล้ว")
    end
  end

  describe 'severity_color' do
    it 'returns the correct color for a valid severity level' do
      expect(report.severity_color).to eq("#FF6159")
    end
  end

  describe 'generated_image_urls' do
    context 'when images are attached' do
      before do
        report.images.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test.jpg')),
          filename: 'test.jpg',
          content_type: 'image/jpg'
        )
      end

      it 'returns an array of image URLs' do
        urls = report.send(:generated_image_urls)
        expect(urls).to be_an(Array)
        expect(urls.first).to include("http")
      end
    end

    context 'when no images are attached' do
      it 'returns an empty array' do
        urls = report.send(:generated_image_urls)
        expect(urls).to eq([])
      end
    end
  end

  describe '#location_within_responsible_areas?' do
    context 'when the report location is within the user areas' do
      it 'does not add an error' do
        report.lat = 15.245
        report.long = 104.860
        report.valid?
        expect(report.errors[:base]).to be_empty
      end
    end

    context 'when the report location is outside the user areas' do
      it 'adds an error' do
        report.lat = 16.0
        report.long = 105.0
        report.valid?
        expect(report.errors[:base]).to include("ตำแหน่งนี้ไม่ได้อยู่ในพื้นที่ที่รับผิดชอบ")
      end
    end
  end

  describe '#parse_tags' do
    context 'when tags is already an Array' do
      it 'returns the original array unchanged' do
        tags_array = [ 'ไฟป่า', 'เผาขยะ' ]
        expect(report.send(:parse_tags, tags_array)).to eq(tags_array)
      end
    end

    context 'when tags is a valid JSON string' do
      it 'parses the JSON into an Array' do
        tags_json = [ 'ไฟป่า', 'เผาขยะ' ].to_json
        expect(report.send(:parse_tags, tags_json)).to eq([ 'ไฟป่า', 'เผาขยะ' ])
      end
    end

    context 'when tags is an invalid JSON string' do
      it 'rescues parsing errors and returns an empty Array' do
        invalid_json = '{invalid:json}'
        expect(report.send(:parse_tags, invalid_json)).to eq([])
      end
    end

    context 'when tags is nil or blank' do
      it 'returns an empty Array' do
        expect(report.send(:parse_tags, nil)).to eq([])
        expect(report.send(:parse_tags, '')).to eq([])
      end
    end
  end

  describe '#invalid_tags?' do
    let(:valid_tags) { %w[ไฟป่า เผาขยะ] }
    let(:invalid_tags) { %w[ไฟป่า invalid_tag] }

    it 'returns false if all tags are in the whitelist' do
      expect(report.send(:invalid_tags?, valid_tags)).to be false
    end

    it 'returns true if any tag is not in the whitelist' do
      expect(report.send(:invalid_tags?, invalid_tags)).to be true
    end

    it 'returns false for an empty array' do
      expect(report.send(:invalid_tags?, [])).to be false
    end
  end

  describe '#tags_must_be_valid' do
    subject { report.valid? }

    context 'with only valid tags' do
      before do
        allow(report).to receive(:tags).and_return([ 'ไฟป่า', 'เผาขยะ' ].to_json)
      end

      it 'does not add any errors on :tags' do
        report.send(:tags_must_be_valid)
        expect(report.errors[:tags]).to be_empty
      end
    end

    context 'with at least one invalid tag' do
      before do
        allow(report).to receive(:tags).and_return([ 'ไฟป่า', 'invalid_tag' ].to_json)
      end

      it 'adds a validation error on :tags' do
        report.send(:tags_must_be_valid)
        expect(report.errors[:tags]).to include('มีค่าไม่ถูกต้อง')
      end
    end
  end

  describe '#generated_image_urls' do
    context 'when no images are attached' do
      before do
        allow(report.images).to receive(:attached?).and_return(false)
      end

      it 'returns an empty Array' do
        expect(report.send(:generated_image_urls)).to eq([])
      end
    end

    context 'when images are attached' do
      before do
        report.images.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test.jpg')),
          filename: 'test.jpg',
          content_type: 'image/jpg'
        )
        # Mock Rails.application.routes.url_helpers to avoid real URL generation
        allow(Rails.application.routes).to receive(:url_helpers).and_return(
          double(minio_proxy_url: '/minio/test.jpg')
        )
      end

      context 'in development environment' do
        before do
          allow(Rails.env).to receive(:development?).and_return(true)
          allow(Rails.env).to receive(:production?).and_return(false)
        end

        it 'builds URLs with http and localhost:3000' do
          urls = report.send(:generated_image_urls)
          expect(urls).to be_an(Array)
          expect(urls.first).to eq('/minio/test.jpg')
          # Since we've mocked url_helpers, we just verify it was called with right params
          expect(Rails.application.routes.url_helpers).to have_received(:minio_proxy_url)
            .with(anything, hash_including(protocol: 'http', host: 'localhost:3000'))
        end
      end

      context 'in production environment' do
        before do
          allow(Rails.env).to receive(:development?).and_return(false)
          allow(Rails.env).to receive(:production?).and_return(true)
        end

        it 'builds URLs with https and ubon-fahsai-dev.odd.works' do
          urls = report.send(:generated_image_urls)
          expect(urls).to be_an(Array)
          expect(urls.first).to eq('/minio/test.jpg')
          # Since we've mocked url_helpers, we just verify it was called with right params
          expect(Rails.application.routes.url_helpers).to have_received(:minio_proxy_url)
            .with(anything, hash_including(protocol: 'https', host: 'ubon-fahsai-dev.odd.works'))
        end
      end
    end
  end
end
