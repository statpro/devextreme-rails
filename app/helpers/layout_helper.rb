module LayoutHelper

  def title(title)
    content_for(:title) { (content_for?(:title) ? ' ' : '') + h(title.to_s) }
  end

  def robots(value)
    content_for(:robots) { h(value.to_s) }
  end

  def stylesheet(*args)
    content_for(:css) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    # FIXME: place javascripts after the footer instead of the head
    content_for(:javascript) { javascript_include_tag(*args) }
  end

  def head(&block)
    content_for(:head, &block)
  end

  def other_body_content(&block)
    content_for(:other_body_content, &block)
  end

end
