class BasicActionsController < ApplicationController
  
  siesta :grand_parents, :parents, :children, :actions => :all
  
end