class OverridingActionsController < Siesta::Controller(:somethings)

  def index; super; end
  def new; super; end
  def create; super; end
  def edit; super; end
  def update; super; end
  def delete; super; end
  
end