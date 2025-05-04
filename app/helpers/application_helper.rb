module ApplicationHelper
  def active_link_class(path)
    request.path.start_with?(path) ? "bg-[#FF6159] text-white" : "bg-white text-gray-500 hover:bg-gray-50 transition-all"
  end

  def breadcrumb_links
    labels = {
      "dashboard" => { "index" => "หน้าหลัก" },
      "areas"     => {
        "index"  => "จัดการพื้นที่",
        "new"    => "เพิ่มพื้นที่",
        "edit"   => "แก้ไขพื้นที่",
        "show"   => "รายละเอียด",
        "create" => "เพิ่มพื้นที่",
        "update" => "แก้ไขพื้นที่"
      }
    }
    
    links = []
    controller_label = labels[controller_name] || { controller_name => controller_name.titleize }
    controller_path = url_for(controller: controller_name, action: :index)
    links << link_to(
      controller_label["index"] || controller_label[controller_name],
      controller_path,
      class: "hover:scale-[1.02] transition-all"
    )

    unless action_name == "index"
      action_label = controller_label[action_name] || action_name.titleize
      current_path = url_for(controller: controller_name, action: action_name)
      links << link_to(action_label, current_path, class: "hover:scale-[1.02] transition-all")

      if links.last && links.last.include?(action_label)
        links.pop
        links << action_label
      end
    end

    links.join('<span class="text-gray-100 font-thin"> / </span>').html_safe
  end
end
