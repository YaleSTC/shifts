class Link < Notice
	validate :proper_url
  named_scope :active,  :conditions => ["end_time = ? ", nil]
  
	private
	def proper_url
		errors.add_to_base "Your link must have a URL" if self.url.empty? || self.url == "http://"
	end

end
