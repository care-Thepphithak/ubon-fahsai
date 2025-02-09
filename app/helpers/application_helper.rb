module ApplicationHelper
  def button_helper(text, variant: :solid, size: :md, icon: nil, iconEnd: nil, css_class: nil, type: 'button', **options)
    variant_classes = {
      solid: "bg-[#FF6159] text-white hover:bg-[#FF6C64]",
      subtle: "bg-[#FF6159] text-white hover:bg-[#FF6C64]",
      surface: "bg-[#FF6159] text-white hover:bg-[#FF6C64]",
      outline: "border border-[#FF6159] text-[#FF6159] hover:bg-[#FF6C64]",
      ghost: "text-[#FF6159] hover:bg-blue-50",
      plain: "text-[#FF6159] hover:scale-[1.01] hover:text-[#FF6C64]"
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
end