require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/models'

class ActsAsCSVExportableTest < Test::Unit::TestCase
  def setup
    @time = Time.now + 2.weeks
    @client = Client.new(:first_name => "Joe", :last_name => "Schmoe")
    @project = Project.new(:name => "My Project", :description => "Described", :deadline => @time)
    
    #fill associations on both sides
    @client.projects << @project
    @project.client = @client
  end
  
    def test_project_default_template_is_set_as_defined_in_model
      assert_equal Project.get_export_template(:default), [{:project_name => :name}, {:project_description => :description}, {:client_name => 'client.full_name'}, {:deadline => 'formatted_deadline'}]
    end
  
    def test_project_simple_template_is_set_as_defined_in_model
      assert_equal Project.get_export_template(:simple), [{:project_name => :name}]
    end
  
    def test_to_csv_should_render_correct_results
      assert_equal "Project Name,Project Description,Client Name,Deadline\nMy Project,Described,Joe Schmoe,#{@time.strftime('%m/%d/%Y')}\n", @client.projects.to_csv    
    end
  
    def test_to_csv_with_template_specified_should_render_correct
      assert_equal "Project Name\nMy Project\n", @client.projects.to_csv(:template => :simple)
    end
  
    def test_to_csv_works_when_columns_specified
      assert_equal "Project Description,Project Name\n#{@project.description},#{@project.name}\n", @client.projects.to_csv(:columns => [{:project_description => :description}, {:project_name => :name}])
    end
  
    def test_to_csv_works_with_chained_methods_when_columns_specified                                                                                                                                  
      assert_equal "Project Description,Project Name,Client\n#{@project.description},#{@project.name},#{@project.client.full_name}\n",  @client.projects.to_csv(:columns => [{:project_description => :description}, {:project_name => :name}, {:client => "client.full_name"}])
    end

end