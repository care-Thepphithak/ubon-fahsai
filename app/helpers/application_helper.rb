module ApplicationHelper
  def button_helper(text, variant: :solid, size: :md, icon: nil, iconEnd: nil, css_class: nil, type: "button", **options)
    variant_classes = {
      solid: "bg-[#FF6159] text-white hover:bg-[#FF6C64]",
      subtle: "bg-[#FF6159] text-white hover:bg-[#FF6C64]",
      surface: "bg-[#FF6159] text-white hover:bg-[#FF6C64]",
      outline: "border border-[#FF6159] text-[#FF6159] hover:bg-[#FF6C64]",
      ghost: "text-[#FF6159] hover:bg-blue-50",
      plain: "text-[#FF6159] hover:scale-[1.01] hover:text-[#FF6C64]",
      cancel: "text-[#8D8D8D] hover:text-[#5D5D5D]"
    }

    size_classes = {
      sm: "text-sm px-1 py-1 rounded-md",
      md: "text-base px-1 py-2 rounded-lg",
      lg: "text-lg px-1 py-3 rounded-xl",
      xl: "text-2xl px-1 py-4 rounded-xl"
    }

    base_classes = "flex items-center justify-center gap-2 cursor-pointer hover:scale-[1.01] transition-all"
    button_class = [ base_classes, variant_classes[variant.to_sym], size_classes[size.to_sym], css_class ].compact.join(" ")

    options[:class] = button_class
    options[:type] = type

    button_content = []
    button_content << content_tag(:i, "", class: "fa-solid fa-#{icon}") if icon
    button_content << content_tag(:span, text)
    button_content << content_tag(:i, "", class: "fa-solid fa-#{iconEnd}") if iconEnd

    content_tag(:button, button_content.join.html_safe, options)
  end

  def active_link_class(path)
    request.path.start_with?(path) ? "bg-[#FF6159] text-white" : "bg-white text-gray-500 hover:bg-gray-50 transition-all"
  end

  def breadcrumb_links
    labels = {
      "dashboard" => {
        "index" => "หน้าหลัก"
      },
      "areas" => {
        "index" => "จัดการพื้นที่",
        "new" => "เพิ่มพื้นที่",
        "edit" => "แก้ไขพื้นที่",
        "show" => "รายละเอียด",
        "create" => "เพิ่มพื้นที่",
        "update" => "แก้ไขพื้นที่"
      }
    }

    links = []

    controller_label = labels[controller_name] || { controller_name => controller_name.titleize }

    controller_path = url_for(controller: controller_name, action: :index)
    links << link_to(controller_label["index"] || controller_label[controller_name], controller_path, class: "hover:scale-[1.02] transition-all")

    unless action_name == "index"
      action_label = controller_label[action_name] || action_name.titleize
      current_path = url_for(controller: controller_name, action: action_name)
      links << link_to(action_label, current_path, class: "hover:scale-[1.02] transition-all")
    end

    if links.last && links.last.include?(controller_label[action_name] || action_name.titleize)
      links.pop
      links << (controller_label[action_name] || action_name.titleize)
    end

    links.join('<span class="text-gray-100 font-thin"> / </span>').html_safe
  end
end
