require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NamespacedModelsController do

  before(:each) do
    @tridents = mock('TridentProxy', :proxy_target => true)
    @merfolk = mock_model(Creature::Merfolk, :tridents => @tridents)
    
    Creature::Merfolk.stub!(:find).with('1').and_return(@merfolk)
  end

  it "should handle" do
    controller.send(:siesta_config, :resource_chain).should eql(['creature/merfolk'])
  end

  it "should set resources chain correctly" do
    controller.send(:siesta_config, :resource).should eql('weapon/trident')
  end
  
  it "should create methods with demodulized names" do
    [:load_merfolk, :load_trident, :load_tridents].each do |method|
      controller.methods.should include(method.to_s)
    end
  end
  
  it 'should perform finds and render the index partial for an index get' do
    
    @paginated_tridents = mock('PaginatedTridents')
    
    @tridents.should_receive(:paginate).with(:page => nil, :include => nil, :conditions => nil, :order => nil).and_return(@paginated_tridents)
    
    get 'index', :merfolk_id => '1'
    
    assigns[:merfolk].should eql(@merfolk)
    assigns[:tridents].should eql(@paginated_tridents)
    
    response.should be_success
    response.should render_template('index')
  end
  
  it 'should performs finds and render the show partial for a show get' do
    @tridents.should_receive(:find).with('3').and_return(@trident)
    
    get 'show', :merfolk_id => '1', :id => '3'
    
    assigns[:merfolk].should eql(@merfolk)
    assigns[:trident].should eql(@trident)
    
    response.should be_success
    response.should render_template('show')
  end
  
  it 'should perform finds and render the new partial for a new get' do
    @tridents.should_receive(:build).with({}).and_return(@trident)
    
    get 'new', :merfolk_id => '1'
    
    assigns[:merfolk].should eql(@merfolk)
    assigns[:trident].should eql(@trident)
    
    response.should be_success
    response.should render_template('new')
  end
  
  it 'should perform finds and render the edit partial for an edit get' do
    @tridents.should_receive(:find).with('3').and_return(@trident)
    
    get 'edit', :merfolk_id => '1', :id => '3'
    
    assigns[:merfolk].should eql(@merfolk)
    assigns[:trident].should eql(@trident)
    
    response.should be_success
    response.should render_template('edit')
  end
  
  it 'should create and redirect for a create post with valid params' do
    @tridents.should_receive(:build).with({'title' => 'A Title'}).and_return(@trident)
    @trident.should_receive(:save)
    @trident.should_receive(:errors).twice.and_return([])
    
    post 'create', :merfolk_id => '1', :trident => {:title => 'A Title'}
    
    response.should be_redirect
    # response.should redirect_to(:controller => 'namespaced_models', :action => 'index')
  end
    
  it 'should fail to create and render the create form for a create post with invalid params' do
    @tridents.should_receive(:build).with({'title' => 'A Title'}).and_return(@trident)
    @trident.should_receive(:save)
    @trident.should_receive(:errors).twice.and_return([:body => 'is required'])
    
    post 'create', :merfolk_id => '1', :trident => {:title => 'A Title'}
    
    response.should render_template('new')
  end
  
  it 'should update and redirect for a update put with valid params' do
    @tridents.should_receive(:find).with('3').and_return(@trident)
    @trident.should_receive(:attributes=).with({'title' => 'A Title'})
    @trident.should_receive(:save)
    @trident.should_receive(:errors).twice.and_return([])
    
    put 'update', :merfolk_id => '1', :id => '3', :trident => {:title => 'A Title'}
    
    response.should be_redirect
    # response.should redirect_to(:controller => 'namespaced_models', :action => 'index')
  end
  
  it 'should fail to update and render the edit form for an update post with invalid params' do
    @tridents.should_receive(:find).with('3').and_return(@trident)
    @trident.should_receive(:attributes=).with({'title' => 'A Title'})
    @trident.should_receive(:save)
    @trident.should_receive(:errors).twice.and_return([:body => 'is required'])
    
    put 'update', :merfolk_id => '1', :id => '3', :trident => {:title => 'A Title'}
    
    response.should render_template('edit')
  end
  
  it 'should destroy and redirect for a delete put' do
    @tridents.should_receive(:find).with('3').and_return(@trident)
    @trident.should_receive(:destroy)
    @trident.should_receive(:errors).twice.and_return([])
    
    delete 'destroy', :merfolk_id => '1', :id => '3'
    
    response.should be_redirect
    # response.should redirect_to(:controller => 'namespaced_models', :action => 'index')
  end
  
  it 'should fail to destroy and render the show page for a failed destroy' do
    @tridents.should_receive(:find).with('3').and_return(@trident)
    @trident.should_receive(:destroy)
    @trident.should_receive(:errors).twice.and_return([:body => 'is required'])
    
    delete 'destroy', :merfolk_id => '1', :id => '3'
    
    response.should render_template('show')
  end
end