
json.caption "#{u.name} #{u.email}"
json.(u, :name, :email, :id, :title)
json.extra render :partial => 'extra', :locals => {:user => u}