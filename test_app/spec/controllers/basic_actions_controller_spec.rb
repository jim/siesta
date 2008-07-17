require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BasicActionsController do

  before(:each) do
    @parents = mock('ParentProxy')
    @children = mock('ChildProxy')
    @grand_parent = mock(GrandParent, :parents => @parents)
    @parent = mock(Parent, :children => @children)
    @child = mock(Child)
  end

  it 'should perform finds and render the index partial for an index get' do
    
    @paginated_children = mock('PaginatedChildren')
    
    GrandParent.should_receive(:find).with('1').and_return(@grand_parent)
    @parents.should_receive(:find).with('2').and_return(@parent)
    @children.should_receive(:paginate).with(:page => nil).and_return(@paginated_children)
    
    get 'index', :grand_parent_id => '1', :parent_id => '2'
    
    assigns[:grand_parent].should eql(@grand_parent)
    assigns[:parent].should eql(@parent)
    assigns[:children].should eql(@paginated_children)
    
    response.should be_success
    response.should render_template('index')
  end
  
  
  it 'should performs finds and render the show partial for a show get' do
    GrandParent.should_receive(:find).with('1').and_return(@grand_parent)
    @parents.should_receive(:find).with('2').and_return(@parent)
    @children.should_receive(:find).with('3').and_return(@child)
    
    get 'show', :grand_parent_id => '1', :parent_id => '2', :id => '3'
    
    assigns[:grand_parent].should eql(@grand_parent)
    assigns[:parent].should eql(@parent)
    assigns[:child].should eql(@child)
    
    response.should be_success
    response.should render_template('show')
  end

  it 'should perform finds and render the edit partial for an edit get' do
    GrandParent.should_receive(:find).with('1').and_return(@grand_parent)
    @parents.should_receive(:find).with('2').and_return(@parent)
    @children.should_receive(:find).with('3').and_return(@child)
    
    get 'edit', :grand_parent_id => '1', :parent_id => '2', :id => '3'
    
    assigns[:grand_parent].should eql(@grand_parent)
    assigns[:parent].should eql(@parent)
    assigns[:child].should eql(@child)
    
    response.should be_success
    response.should render_template('edit')
  end

  it 'should create and redirect for a create post with valid params' do
    GrandParent.should_receive(:find).with('1').and_return(@grand_parent)
    @parents.should_receive(:find).with('2').and_return(@parent)
    @children.should_receive(:build).with({'title' => 'A Title'}).and_return(@child)
    @child.should_receive(:save).and_return(true)
    
    post 'create', :grand_parent_id => '1', :parent_id => '2', :child => {:title => 'A Title'}

    response.should redirect_to('index')
  end

  # 
  # it 'should create and render the create form for a create post with invalid params' do
  #   hash = {'key' => 'value'}
  #   test_model = mock_model(TestModel)
  #   test_model.should_receive(:new_record?).and_return(true)
  #   test_model.should_receive(:save).and_return(false)
  #   TestModel.should_receive(:new).with(hash).and_return(test_model)
  #   
  #   post 'create', :test_model => hash
  #   
  #   assigns[:resource].should eql(test_model)
  #   assigns[:test_model].should eql(test_model)
  #   response.should be_success
  #   response.should render_template('/resources/new')
  # end
  # 
  # it 'should render the edit partial for a get to edit' do
  #   test_model = mock_model(TestModel)
  #   TestModel.should_receive(:find).with('10').and_return(test_model)
  #   
  #   get 'edit', :id => '10'
  #   
  #   assigns[:resource].should eql(test_model)
  #   assigns[:test_model].should eql(test_model)
  #   response.should be_success
  #   response.should render_template('/resources/edit')
  # end
  # 
  # it 'should update and save a model and redirect to the index page for a put to update with valid params' do
  #   test_model = mock_model(TestModel)
  #   hash = {'key' => 'value'}
  #   TestModel.should_receive(:find).with('10').and_return(test_model)
  #   test_model.should_receive(:update_attributes).with(hash).and_return(true)
  #   test_model.should_receive(:valid?).and_return(true)
  # 
  #   put 'update', :id => '10', :test_model => hash
  #   
  #   flash[:info].should_not be_blank
  #   response.should be_redirect
  #   response.should redirect_to('http://test.host/test_models')
  # end
  # 
  # it 'should update and save a model and render the edit template for a put to update with invalid params' do
  #   test_model = mock_model(TestModel)
  #   hash = {'key' => 'value'}
  #   TestModel.should_receive(:find).with('10').and_return(test_model)
  #   test_model.should_receive(:update_attributes).with(hash).and_return(false)
  #   test_model.should_receive(:valid?).and_return(false)
  # 
  #   put 'update', :id => '10', :test_model => hash
  #   
  #   assigns[:resource].should eql(test_model)
  #   assigns[:test_model].should eql(test_model)
  #   response.should be_success
  #   response.should render_template('/resources/edit')
  # end
  # 
  # it 'should find and destroy a model for a delete to destroy' do
  #   test_model = mock_model(TestModel)
  #   TestModel.should_receive(:find).with('10').and_return(test_model)
  #   test_model.should_receive(:destroy).and_return(true)
  # 
  #   delete 'destroy', :id => '10'
  #   
  #   flash[:info].should_not be_blank
  #   response.should be_redirect
  #   response.should redirect_to('http://test.host/test_models')
  # end
  # 
  # it 'should render a default template when it exists' do
  #   test_model = mock_model(TestModel)
  #   TestModel.should_receive(:new).and_return(test_model)
  #   controller.stub!(:template_exists?).and_return(true)
  #   
  #   get 'new'
  #   
  #   response.should be_success
  #   response.should render_template('test_restful/new')
  # end
  # 
  # it "should attempt to find an acts_as_sluggable model by using a slug" do
  #   test_model = mock_model(TestModel)
  #   TestModel.should_receive(:included_modules).and_return([ActiveRecord::Acts::Sluggable::InstanceMethods])
  #   TestModel.should_receive(:find_by_slug).with('a-slug').and_return(test_model)
  #   
  #   get 'show', :id => 'a-slug'
  #   
  #   assigns[:resource].should eql(test_model)
  #   assigns[:test_model].should eql(test_model)
  #   response.should be_success
  #   response.should render_template('/resources/show')
  # end
  # 
  # # The following mock of respond_to breaks rspec for any examples after this one
  #   # 
  #   # it 'should not symbolize and pass through params[:order] to an non acts_as_orderable model' do
  #   #   collection = mock('Collection')
  #   #   TestModel.should_receive(:respond_to?).with(:orderable_by?).and_return(false)
  #   #   TestModel.should_receive(:paginate).with(:all, {:page => nil, :order => nil}).and_return(collection)
  #   #   TestModel.should_not_receive(:paginate).with(:all, {:order => :title, :page => nil}).and_return(collection)
  #   #   
  #   #   get 'index', :order => 'title'
  #   # end
  #   # 
  #   # it 'should symbolize and pass through params[:order] to an acts_as_orderable model' do
  #   #   collection = mock('Collection')
  #   #   TestModel.should_receive(:respond_to?).with(:orderable_by?).and_return(true)
  #   #   TestModel.should_receive(:orderable_by?).with(:title).and_return(true)
  #   #   TestModel.should_receive(:paginate).with(:all, {:order => :title, :page => nil}).and_return(collection)
  #   #   
  #   #   get 'index', :order => 'title'
  #   # end
  #   # 
end