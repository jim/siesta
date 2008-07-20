require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ConfigurationController do

  it "should set resources chain correctly" do
    controller.send(:siesta_config, :resource_chain).should eql(['grand_parent', 'parent'])
  end

  it "should set resources chain correctly" do
    controller.send(:siesta_config, :resource).should eql('child')
  end
  
  it "should set public actions correctly" do
    controller.send(:siesta_config, :public_actions).should eql([:index, :show, :create]) 
    [:index, :show, :create].each do |method|
      controller.methods.should include(method.to_s)
    end
  end

end
