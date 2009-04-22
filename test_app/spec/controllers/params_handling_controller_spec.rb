require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParamsHandlingController do
  
  before(:each) do
    @user = mock_model(User)
    User.stub!(:find).with(1).and_return(@user)
    
    @something = mock_model(Something, :save => true, :errors => [])
  end
  
  it "should merge in create_params when creating" do 
    Something.should_receive(:new).with({'title' => 'title', 'creator' => @user}).and_return(@something)
    post :create, :something => {:title => 'title'}
  end
  
  it "should merge in update_params when updating" do 
    Something.should_receive(:find).with('123').and_return(@something)
    @something.should_receive(:attributes=).with({'title' => 'title', 'updater' => @user})
    
    put :update, :id => '123', :something => {:title => 'title'}
  end

end