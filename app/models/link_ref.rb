class LinkRef
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :rel, :type => String 
  field :link, :type => String
  
  embedded_in :kiwi
  
  def self.create_it(rel: nil, link: nil)
    id = self.new
    id.update_it(rel: rel, link: link)
    id
  end
  
  def update_it(rel: nil, link: nil)
    self.rel = rel
    self.link = link
    self 
  end
    
end
