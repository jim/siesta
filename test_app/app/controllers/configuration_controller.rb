class ConfigurationController < ApplicationController
  
  restful_actions_for :grand_parents, :parents, :children, :actions => [:index, :show, :create]
  
end