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

class Link < Notice

	validate :proper_url
  
  def active?
    self.end == nil 
  end

	private
	def proper_url
		if self.url.empty? || self.url == "http://"
			errors.add_to_base "Your URL cannot be empty"
		elsif self.url.split.first != self.url
			errors.add_to_base "Your URL cannot have white spaces"
		end
	end
end
