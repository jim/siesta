require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OverridingInternalsController do
  
  it "should call custom load method from show" do
    controller.should_receive(:custom_load_something)
    get 'show'
  end
  
  it "should call custom new method from new" do
    controller.should_receive(:custom_new_something)
    get 'new'
  end
  
  it "should call custom edit method from edit" do
    controller.should_receive(:custom_load_something)
    get 'edit'
  end
  
  it "should call custom load method from index" do
    controller.should_receive(:custom_load_somethings)
    get 'index'
  end
  
  it "should call custom create method from create" do
    controller.stub!(:something_created?).and_return(false)
    
    controller.should_receive(:custom_create_something)
    
    post 'create'
  end
  
  it "should call custom update method from update" do
    controller.stub!(:something_updated?).and_return(false)
    
    controller.should_receive(:custom_load_something)
    controller.should_receive(:custom_update_something)
    
    put 'update'
  end
  
  it "should call custom destroy method from destroy" do
    controller.stub!(:something_destroyed?).and_return(false)
    
    controller.should_receive(:custom_load_something)
    controller.should_receive(:custom_destroy_something)
    
    delete 'destroy'
  end

end