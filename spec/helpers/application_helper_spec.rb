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
    # stub url_for ให้คืน path ในรูป "/controller/action"
    allow(helper).to receive(:url_for) do |**opts|
      "/#{opts[:controller]}/#{opts[:action]}"
    end

    # stub link_to ให้คืน HTML ง่ายๆ
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

    # context "เมื่ออยู่ที่ action new" do
    #   before do
    #     allow(helper).to receive(:controller_name).and_return("areas")
    #     allow(helper).to receive(:action_name).and_return("new")
    #   end

    #   it "จะแสดงลิงก์ไปยัง index ก่อน แล้วตามด้วยชื่อ action (ไม่เป็นลิงก์)" do
    #     output = helper.breadcrumb_links

    #     # คาดว่าเริ่มด้วย link ไปยังจัดการพื้นที่
    #     expect(output).to start_with(%r{<a href="/areas/index"[^>]*>จัดการพื้นที่</a>})
    #     # ต้องมี separator
    #     expect(output).to include('<span class="text-gray-100 font-thin"> / </span>')
    #     # ท้ายสุดต้องเป็นข้อความ "เพิ่มพื้นที่" ไม่ใช่ลิงก์
    #     expect(output).to end_with("เพิ่มพื้นที่")
    #     # ไม่มีลิงก์ซ้ำของ "เพิ่มพื้นที่"
    #     expect(output.scan(/>เพิ่มพื้นที่</).size).to eq 1
    #   end
    # end

    # context "เมื่อ action ไม่มีใน labels hash" do
    #   before do
    #     allow(helper).to receive(:controller_name).and_return("widgets")
    #     allow(helper).to receive(:action_name).and_return("show")
    #   end

    #   it "จะใช้ titleize สำหรับ controller และ action แทน" do
    #     output = helper.breadcrumb_links

    #     # controller_name titleize เป็น "Widgets"
    #     expect(output).to start_with(%r{<a href="/widgets/index"[^>]*>Widgets</a>})
    #     # action_name titleize เป็น "Show"
    #     expect(output).to include("Show")
    #   end
    # end

    context "เมื่อ action กับ label ซ้ำกับ controller label" do
      before do
        # สมมติ controller_name และ action_name เท่ากัน
        allow(helper).to receive(:controller_name).and_return("dashboard")
        allow(helper).to receive(:action_name).and_return("index")
      end

      it "จะไม่ซ้ำลิงก์เดิม และยังคงแสดงผลถูกต้อง" do
        output = helper.breadcrumb_links
        # dashboard/index มี label เป็น "หน้าหลัก"
        expect(output).to eq('<a href="/dashboard/index" class="hover:scale-[1.02] transition-all">หน้าหลัก</a>')
      end
    end
  end
end
