require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/models'

class ActsAsCSVVImportableTest < Test::Unit::TestCase

  def setup
    @def_file = File.open(File.dirname(__FILE__) + '/default_template_test.csv')
    
    @user_defined_file = File.open(File.dirname(__FILE__) + '/user_defined_template_test.csv')
    @adv_file = File.open(File.dirname(__FILE__) + '/advanced_template_test.csv')
    
  end
  
  def test_file_import_runs_on_default_template
    @projects = Project.from_csv(@def_file)
    assert_equal 3, @projects.size
    assert_equal "My Project", @projects.first.name
    assert_equal "Building Something", @projects.last.description
  end
  
  def test_file_import_runs_on_user_defined_template

    @projects = Project.from_csv(@user_defined_file, :user_defined)
    assert_equal 3, @projects.size
    
    assert_equal "My Project", @projects.first.name
    assert_equal "Building Something", @projects.last.description
  end
  
  def test_objects_without_id_are_new_records
    @projects = Project.from_csv(@user_defined_file, :user_defined)
    
    # the first record should be a new record
    assert @projects.first.new_record?
    
    # the second record should be a new record
    assert @projects[1].new_record?
    
    # the third (and last) should NOT be a new record
    assert !@projects.last.new_record?
  end
  
  def test_object_load_works
    @projects = Project.from_csv(@user_defined_file, :user_defined)
    @p = Project.find(1)
    assert_equal @p.client, @projects.last.client
  end
  
  def test_custom_method_import
    @projects = Project.from_csv(@adv_file, :advanced)
    
    @c = Client.find(1)
    
    assert_equal @c, @projects.first.client
    assert_equal @c, @projects.last.client
    
    assert_equal "Joe Schmoe", @projects[1].client.full_name
  end 
  
  def test_sdomething
    puts Mime::Type.lookup_by_extension('html').inspect
    puts Mime::Type.lookup_by_extension('csv').inspect
  end
    
end