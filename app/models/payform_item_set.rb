# == Schema Information
#
# Table name: payform_item_sets
#
#  id             :integer          not null, primary key
#  category_id    :integer
#  date           :date
#  hours          :decimal(10, 2)
#  description    :text
#  active         :boolean
#  approved_by_id :integer
#

class PayformItemSet < ActiveRecord::Base

  has_many :payform_items
  belongs_to :category
  delegate :department, to: :category
  validates_presence_of :description, :hours, :date, :category_id
  validate :payform_item_creation
  delegate :users, to: :payform_items

  scope :active, where(active: true)
  scope :expired, where(active: false)

  def users
    return self.payform_items.collect { |item| item.user }.compact
  end

private
  def payform_item_creation
    errors.add("Users did not add properly.", "") if PayformItem.where(payform_item_set_id: self.id).first == nil
  end

end

