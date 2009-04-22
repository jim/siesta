class ParamsHandlingController < ApplicationController
  
  before_filter :load_user
  
  siesta :somethings, :actions => [:create, :update]
  
  protected
  
  def create_params
    {:creator => @user}
  end
  
  def update_params
    {:updater => @user}    
  end
  
  def load_user
    @user = User.find(1)
  end
  
end