# == Schema Information
#
# Table name: categories
#
#  id            :integer          not null, primary key
#  active        :boolean          default(TRUE)
#  built_in      :boolean          default(FALSE)
#  name          :string(255)
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  billing_code  :string(255)
#

class Category < ActiveRecord::Base
  belongs_to :department
  has_many :payform_items
  has_many :locations

  validates_presence_of :name, :department_id
  validates_uniqueness_of :name, scope: :department_id

  scope :disabled, where(active: false)
  scope :active, where(active: true)
  scope :built_in, where(built_in: true)
  scope :usable, where(active: true, built_in: false)

  def self.enabled
    Category.where(active: true)
  end

  protected


end

