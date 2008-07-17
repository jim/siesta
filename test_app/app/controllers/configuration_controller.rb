class ConfigurationController < ApplicationController
  
  restful_actions_for :grand_parents, :parents, :children, :public => :all
  
end