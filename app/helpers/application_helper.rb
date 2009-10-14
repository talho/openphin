module ApplicationHelper
  def current_user
    user = super
    present user if user 
  end
  
  def s(str,options=nil)
    content_tag :span, str, options
  end

  def d(str,options=nil)
    content_tag :div, str, options
  end
end