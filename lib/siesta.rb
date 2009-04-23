require File.join(File.dirname(__FILE__), 'siesta/controller')

module Siesta
  VERSION = 0.3
  
  # Dynamically creates a controller that provides standard REST-based actions for any resource,
  # including nested resources.
  def self.Controller(*models)
    Controller.build(ApplicationController, *models)
  end
  
end