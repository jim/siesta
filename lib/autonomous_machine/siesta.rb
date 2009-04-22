require File.join(File.dirname(__FILE__), 'siesta/controller')

module AutonomousMachine::Siesta
  VERSION = 0.2
end

ActionController::Base.send(:include, AutonomousMachine::Siesta::Controller)