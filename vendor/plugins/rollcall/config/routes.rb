ActionController::Routing::Routes.draw do |map|
  map.rollcall "/rollcall", :controller => "rollcall", :action => "index"
end