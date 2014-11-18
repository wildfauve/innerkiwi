class Port

  def link_for(rel: nil)
    @msg["_links"][rel.to_s]["href"]
  end
  
end
