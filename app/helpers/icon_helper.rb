module IconHelper

  def icon_tag(*icons)
    options = icons.extract_options!
    content_tag(:i, options.merge(:class => icon_class(*icons) + (options[:class] || [])) ) do
    end
  end

  def icon_tag_spin(*icons)
    options = icons.extract_options!
    content_tag(:i, options.merge(:class => icon_class_spin(*icons) + (options[:class] || [])) ) do
    end
  end

  def icon_class(*icons)
    %w(fa) + icons.map{|i| "fa-#{i.to_s}"}
  end

  def icon_class_spin(*icons)
    %w(fa) + icons.map{|i| "fa-#{i.to_s} fa-spin"}
  end

end
