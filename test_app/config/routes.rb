ActionController::Routing::Routes.draw do |map|

  map.resources :grand_parents do |grand_parents|
    grand_parents.resources :parents do |parents|
      parents.resources :children
    end
  end
  
  map.resources :somethings
  
  map.resources :merfolks do |merfolks|
    merfolks.resources :tridents
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
