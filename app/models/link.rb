class Link < Notice

	validate :proper_url
  named_scope :active,  :conditions => ["end_time = ? ", nil]

	private
	def proper_url
		if self.url.empty? || self.url == "http://"
			errors.add_to_base "Your URL cannot be empty"
		elsif self.url.split.first != self.url
			errors.add_to_base "Your URL cannot have white spaces"
		end
	end
end
