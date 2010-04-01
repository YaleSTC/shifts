class String
  
  def links
    temp = self
    # link# without http doesn't work right now. I think it needs to be fixed with | (pipe symbol), not sure how to implement
    # beware of order of the gsub!s. the link one should be done first, since we don't want it to re-link the links after.
    temp.gsub!(/([Ll]ink#)?(http:\/\/[0-9a-zA-z_\/.\-;:?=&+%]+)([, $'"]?)/,"<a href=#{'\2'}>#{'\2'}</a>#{'\3'}")
    temp.gsub!(/([Rr][Tt]#)([0-9]+)/,"<a href=http://uhu.its.yale.edu/Ticket/Display.html?id=#{'\2'}>#{'\1\2'}</a>")
    temp.gsub!(/([Ww]eke#)([0-9a-zA-Z_]+)([., $'"]?)/,"<a href=http://weke.its.yale.edu/wiki/index.php/Special:Search?search=#{'\2'}&go=Go>#{'\1\2'}</a>#{'\3'}")
    temp.gsub!(/\b[Ii][Oo]\b/,"USS Ticonderoga")
    temp.gsub!(/TTO/,"USS Nimitz")
    temp.gsub!(/tto/,"USS Nimitz")
    temp.gsub!(/[Bb]ass/,"USS Abe Lincoln")
    temp.gsub!(/[Cc][Tt][Hh]all/,"USS John F. Kennedy")
    temp.gsub!(/[Dd]unham/,"USS George H. W. Bush")
    temp.gsub!(/\b[Hh]ello/,"ahoy")
    temp.gsub!(/\b[Ss]hift/,"voyage")
    temp.gsub!(/\b[Aa]dam\b/,"Admiral Adam")
    # temp.gsub!(/([Rr]eport#)([0-9]+)/, ActionView::Helpers::UrlHelper::link_to('\1\2', :controller => :report, :action => :view, :id => '\1'))
    temp
  end
  
  def n_to_br
    gsub(/\n/,"<br />")
  end
  
  def h
    ERB::Util::h self
  end
  
  def sanitize_and_format
    h.links.n_to_br
  end
  
  def decamelize
    gsub(' ','_').downcase
  end
  
end
