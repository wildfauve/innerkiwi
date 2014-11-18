json.kind "kiwi"
json.name @kiwi.name
json.age @kiwi.age
json.social do
  json.twitter_handle @kiwi.twitter_handle
end
json.products @kiwi.purchases do |purchase|
  json._links do
    json.product_origination do
      json.href purchase.origination_link
    end
    json.product do
      json.href purchase.product_link
    end
    json.account do
      json.href purchase.account_link
    end
  end  
end
json._links do
  json.self do
    json.href api_v1_kiwi_url(@kiwi)
  end
  json.customer do
    json.href @kiwi.party_url
  end
  @kiwi.link_refs.each do |link|
    json.set! link.rel.to_sym, link.link
  end
end