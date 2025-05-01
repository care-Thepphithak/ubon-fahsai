require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#active_link_class' do
    let(:path) { '/areas' }

    context 'when the request path starts with the given path' do
      before do
        allow(helper.request).to receive(:path).and_return('/areas/edit')
      end

      it 'returns the active class' do
        expect(helper.active_link_class(path)).to eq('bg-[#FF6159] text-white')
      end
    end

    context 'when the request path does not start with the given path' do
      before do
        allow(helper.request).to receive(:path).and_return('/dashboard')
      end

      it 'returns the default class' do
        expect(helper.active_link_class(path)).to eq('bg-white text-gray-500 hover:bg-gray-50 transition-all')
      end
    end
  end
end
