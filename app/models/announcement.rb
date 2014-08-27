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

class Announcement < Notice

  scope :active, -> {where("start <= ? AND end is ? OR end > ?", Time.now.utc, nil, Time.now.utc) }
  scope :upcoming, -> {where("start > ?", Time.now.utc)}
  scope :ordered_by_start, order('start')

  def active?
    self.start <= Time.now && (self.end == nil || self.end > Time.now)
  end

end
