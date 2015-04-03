class PayformItemSet < ActiveRecord::Base

  has_many :payform_items
  belongs_to :category
  delegate :department, to: :category
  validates_presence_of :description, :hours, :date, :category_id
  after_save :payform_item_creation # Cannot check if records are saved before the parent is saved
  delegate :users, to: :payform_items

  scope :active, where(active: true)
  scope :expired, where(active: false)

  def users
    return self.payform_items.collect { |item| item.user }.compact
  end

private
  def payform_item_creation
    raise("Users did not add properly.") if PayformItem.where(payform_item_set_id: self.id).first == nil
  end

end

