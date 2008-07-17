require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ConfigurationController do

  it "should set resources chain correctly" do
    controller.class.siesta_config[:resource_chain].should eql(['grand_parent', 'parent'])
  end

  it "should set resources chain correctly" do
    controller.class.siesta_config[:resource].should eql('child')
  end

end
