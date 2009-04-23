class ParamsHandlingController < Siesta::Controller(:somethings)
  
  before_filter :load_user
  
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