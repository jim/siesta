class OverridingInternalsController < ApplicationController
  
  siesta :somethings, :actions => :all

  protected

  def load_somethings
    custom_load_somethings
  end
  
  def load_something
    custom_load_something
  end
  
  def new_something
    custom_new_something
  end
  
  def create_something
    custom_create_something
  end
  
  def destroy_something
    custom_destroy_something
  end
  
  def edit_something
    custom_load_something
  end
  
  def update_something
    custom_update_something
  end
end