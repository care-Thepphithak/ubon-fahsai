require 'rails_helper'

RSpec.describe TrendComparison, type: :concern do
  # Create a dummy class to test the concern
  class DummyController
    include TrendComparison
  end

  let(:controller) { DummyController.new }

  describe '#compare_counts' do
    context "when today's count is greater than yesterday's" do
      it 'returns :increased' do
        expect(controller.compare_counts(10, 5)).to eq(:increased)
      end
    end

    context "when today's count is less than yesterday's" do
      it 'returns :decreased' do
        expect(controller.compare_counts(5, 10)).to eq(:decreased)
      end
    end

    context "when today's count equals yesterday's" do
      it 'returns :unchanged' do
        expect(controller.compare_counts(5, 5)).to eq(:unchanged)
      end
    end

    context 'with edge cases' do
      it 'handles zero values correctly' do
        expect(controller.compare_counts(0, 0)).to eq(:unchanged)
        expect(controller.compare_counts(5, 0)).to eq(:increased)
        expect(controller.compare_counts(0, 5)).to eq(:decreased)
      end

      it 'handles negative values correctly' do
        expect(controller.compare_counts(-1, -5)).to eq(:increased)
        expect(controller.compare_counts(-5, -1)).to eq(:decreased)
        expect(controller.compare_counts(-5, -5)).to eq(:unchanged)
      end
    end
  end
end
