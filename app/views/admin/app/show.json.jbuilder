
json.partial! 'admin/app/app', app: @app
json.logo_url @app.logo.url(:full)
json.logo_thumb_url @app.logo.url(:thumb)
json.tiny_logo_url @app.tiny_logo.url(:full)
json.tiny_logo_thumb_url @app.tiny_logo.url(:thumb)
json.roles @app.roles do |json, role|
  json.partial! 'admin/roles/role', role: role
end
