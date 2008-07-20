class BasicActionsController < ApplicationController
  
  siesta :grand_parents, :parents, :children, :actions => :all
  
  def allowed_params
    %w(title)
  end
  
end