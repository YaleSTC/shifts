class Link < Notice
	validates_presence_of :url
  validate :proper_url

private
  def proper_url
    url = self.url
    unless url.slice(0,7) == "http://" or url.slice(0,8) == "https://"
      errors.add_to_base "Your url must begin with http:// or https://"
    end
  end
end
