class OverridingActionsController < ApplicationController
  
  siesta :somethings, :actions => :all

  def new
    super
  end
  
  protected
  
  def load_something
    custom_load_something
  end
  
  def create_something
    custom_create_something
    super
  end

  def custom_load_something; end
  def custom_new_something; end
  def custom_create_something; end
end