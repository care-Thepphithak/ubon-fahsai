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

  describe "#breadcrumb_links" do
  before do
    allow(helper).to receive(:url_for) do |**opts|
      "/#{opts[:controller]}/#{opts[:action]}"
    end

    allow(helper).to receive(:link_to) do |label, path, **html_opts|
      "<a href=\"#{path}\" class=\"#{html_opts[:class]}\">#{label}</a>".html_safe
    end
  end

  context "when action is index" do
    before do
      allow(helper).to receive(:controller_name).and_return("areas")
      allow(helper).to receive(:action_name).and_return("index")
    end

    it "renders a single link to the index page" do
      output = helper.breadcrumb_links
      expect(output).to match %r{\A<a href="/areas/index"[^>]*>จัดการพื้นที่</a>\z}
      expect(output).not_to include(' / ')
    end
  end

    context "When at action new." do
      before do
        allow(helper).to receive(:controller_name).and_return("areas")
        allow(helper).to receive(:action_name).and_return("new")
      end

      it "It will show a link to the index first, followed by the action name (not a link)." do
        output = helper.breadcrumb_links
        expect(output).to start_with(%r{<a href="/areas/index"[^>]*>จัดการพื้นที่</a>})
        expect(output).to include('<span class="text-gray-100 font-thin"> / </span>')
        expect(output).to end_with("เพิ่มพื้นที่")
        expect(output.scan(/>เพิ่มพื้นที่</).size).to eq 1
      end
    end

    context "When action does not exist in hash labels." do
      before do
        allow(helper).to receive(:controller_name).and_return("widgets")
        allow(helper).to receive(:action_name).and_return("show")
      end

      it "Use titleize for controllers and actions instead." do
        output = helper.breadcrumb_links
        expect(output).to start_with(%r{<a href="/widgets/index"[^>]*>Widgets</a>})
        expect(output).to include("Show")
      end
    end

    context "When an action and label duplicate a controller label" do
      before do
        allow(helper).to receive(:controller_name).and_return("dashboard")
        allow(helper).to receive(:action_name).and_return("index")
      end

      it "It will not duplicate the original link and will still display correctly." do
        output = helper.breadcrumb_links
        expect(output).to eq('<a href="/dashboard/index" class="hover:scale-[1.02] transition-all">หน้าหลัก</a>')
      end
    end
  end
end
