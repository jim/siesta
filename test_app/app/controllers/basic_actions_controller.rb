class BasicActionsController < ApplicationController
  
  restful_actions_for :grand_parents, :parents, :children, :actions => :all
  
  def allowed_params
    %w(title)
  end
  
end