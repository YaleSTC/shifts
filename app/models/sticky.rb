# == Schema Information
#
# Table name: notices
#
#  id              :integer          not null, primary key
#  sticky          :boolean          default(FALSE)
#  useful_link     :boolean          default(FALSE)
#  announcement    :boolean          default(FALSE)
#  indefinite      :boolean
#  content         :text
#  author_id       :integer
#  start           :datetime
#  end             :datetime
#  department_id   :integer
#  remover_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  url             :string(255)
#  type            :string(255)
#  department_wide :boolean
#

class Sticky < Notice
  
  scope :ordered_by_start, order('start')
    
  def active?
    self.end == nil || self.end > Time.now
  end
  
	EXPIRE_ON = [
    ["day",  "day"],
    ["week", "week"],
		["month", "month"]
  ]

end
