require File.join(File.dirname(__FILE__), 'siesta/controller')
ActionController::Base.send(:include, AutonomousMachine::Siesta::Controller)