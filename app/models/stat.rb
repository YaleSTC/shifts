require 'active_record/validations'

class Stat

  # Define your arbitrary PORO attributes.
  attr_accessor :id
  attr_accessor :start_date
  attr_accessor :end_date

  # For the ActiveRecord::Errors object.
  attr_accessor :errors

  def initialize(opts = {})

  # Create an Errors object, which is required by validations and to use some view methods.
    @errors = ActiveRecord::Errors.new(self)
  end

  # Dummy stub to make validtions happy.
  def save
  end

  # Dummy stub to make validtions happy.
  def save!
  end

  # Dummy stub to make validtions happy.
  def new_record?
    false
  end

  # Dummy stub to make validtions happy.
  def update_attribute
  end

  # Mix in that validation goodness!
  include ActiveRecord::Validations

  # Use validations.
  validates_presence_of :id
  validates_presence_of :start_date
  validates_presence_of :end_date

end