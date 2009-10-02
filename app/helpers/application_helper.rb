module ApplicationHelper
  def current_user
    user = super
    present user if user 
  end
  
  def s(str)
    "<span>#{str}</span>"
  end
end