require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OverridingActionsController do

  it "should call custom load_something in place of default" do
    controller.should_receive(:custom_load_something)

    get 'show', :id => '123'
  end

  it "should call the default behavior when super is called" do
    @something = mock_model(Something, :save => true, :errors => [])
    
    controller.should_receive(:custom_create_something)
    Something.should_receive(:new).and_return(@something)
    
    post 'create'
  end

end