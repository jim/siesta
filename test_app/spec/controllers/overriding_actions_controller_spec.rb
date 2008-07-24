require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OverridingActionsController do

  it "should call default actions using super from within show" do
    controller.should_receive(:load_something)
    controller.should_receive(:respond_to_show)
    get 'show', :id => '123'
  end

  it "should call default actions using super from within create" do
    controller.should_receive(:create_something)
    controller.should_receive(:report)
    controller.should_receive(:message_for_create_success)
    controller.should_receive(:something_created?).and_return(true)
    controller.should_receive(:respond_to_create)
    post 'create', :id => '123'
  end
  
  it "should call default actions using super from within update" do
    controller.should_receive(:load_something)
    controller.should_receive(:update_something)
    controller.should_receive(:report)
    controller.should_receive(:message_for_update_success)
    controller.should_receive(:something_updated?).and_return(true)
    controller.should_receive(:respond_to_update)
    post 'update', :id => '123'
  end
  
  it "should call default actions using super from within destroy" do
    controller.should_receive(:load_something)
    controller.should_receive(:destroy_something)
    controller.should_receive(:report)
    controller.should_receive(:message_for_destroy_success)
    controller.should_receive(:something_destroyed?).and_return(true)
    controller.should_receive(:respond_to_destroy)
    post 'destroy', :id => '123'
  end

  it "should call default actions using super from within edit" do
    controller.should_receive(:load_something)
    controller.should_receive(:respond_to_edit)
    get 'edit', :id => '123'
  end

  it "should call default actions using super from within new" do
    controller.should_receive(:new_something)
    controller.should_receive(:respond_to_new)
    get 'new', :id => '123'
  end

  it "should call default actions using super from within index" do
    controller.should_receive(:load_somethings)
    controller.should_receive(:respond_to_index)
    get 'index', :id => '123'
  end

end