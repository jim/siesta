class OverridingActionsController < ApplicationController
  
  siesta :somethings, :actions => :all

  def index; super; end
  def new; super; end
  def create; super; end
  def edit; super; end
  def update; super; end
  def delete; super; end
  
end