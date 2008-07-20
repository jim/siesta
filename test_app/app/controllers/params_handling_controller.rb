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
  
  def allowed_params
    [:title, :body]
  end
  
  def load_user
    @user = User.find(1)
  end
  
end