ActionView::Base.sanitized_allowed_tags = ['font']
ActionView::Base.sanitized_allowed_attributes = 'size', 'style', 'align', 'color', 'face', 'target', 'tab'

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  "<span class=\"error\">#{html_tag}</span>".html_safe
end