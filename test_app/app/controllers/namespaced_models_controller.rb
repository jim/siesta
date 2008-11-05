class NamespacedModelsController < ApplicationController
  siesta 'Creature::Merfolks', 'Weapon::Tridents', :actions => :all
  
  protected
  
  def allowed_params
    [:title]
  end
end