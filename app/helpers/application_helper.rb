module ApplicationHelper
  def current_user
    user = super
    present user if user 
  end
end