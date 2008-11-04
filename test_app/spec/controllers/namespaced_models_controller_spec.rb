require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NamespacedModelsController do

  it "should handle" do
    controller.send(:siesta_config, :resource_chain).should eql(['creatures/merfolk'])
  end

  it "should set resources chain correctly" do
    controller.send(:siesta_config, :resource).should eql('weapons/trident')
  end
  
  it "should create methods with demodulized names" do
    [:load_merfolk, :load_trident, :load_tridents].each do |method|
      controller.methods.should include(method.to_s)
    end
  end

end
