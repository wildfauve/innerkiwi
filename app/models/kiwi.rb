class Kiwi
  
  include Wisper::Publisher

  include Mongoid::Document
  include Mongoid::Timestamps  
  
  include UrlHelpers
  
  field :name, type: String
  field :age, type: Integer
  field :twitter_handle, type: String
  field :party_url, type: String
  
  has_one :user_proxy, autosave: true
  
  embeds_many :purchases
  
  embeds_many :link_refs
  
  def create_me(cust: nil, current_user_proxy: nil)
    raise if !current_user_proxy
    self.update_attrs(cust: cust, current_user_proxy: current_user_proxy )
    party = CustomerPort.new.create_new_customer(self)
    self.create_links(party: party)
    self.save
    publish(:successful_save_event, self)
  end
  
  def update_me(cust: nil, current_user_proxy: nil)
    raise if !current_user_proxy
    self.update_attrs(cust: cust, current_user_proxy: current_user_proxy )
    party = CustomerPort.new.update_customer(self) if (cust.keys & ["name", "age"]).present?
    self.save
    publish(:successful_save_event, self)
  end
  
  
  def update_attrs(cust: nil, current_user_proxy: nil)
    raise if !current_user_proxy
    self.name = cust[:name]
    self.age = cust[:age]
    self.twitter_handle = cust[:twitter_handle]
    self.user_proxy = current_user_proxy    
  end
  
  def check_party
    party = CustomerPort.new.get_customer(url: self.party_url)
    self.create_links(party: party)
    self.name = party["party"]["name"] if self.name != party["party"]["name"]
    self.age = party["party"]["age"] if self.age != party["party"]["age"]
    self.save
  end
  
  def create_links(party: nil)
    party["_links"].each do |rel, link|
      if rel == "self"
        self.party_url = link["href"]
      else
        self.add_link_refs(rel: rel, link: link["href"])
      end
    end
  end
  
  def add_link_refs(rel: nil, link: nil)
    ref = self.link_refs.where(rel: rel).first
    if ref
      ref.update_it(rel: rel, link: link)
    else
      self.link_refs << LinkRef.create_it(rel: rel, link: link)
    end
    self.save
  end
  
  def add_purchase(buy: nil)
    purchase = Purchase.create_me(buy: buy)
    self.purchases << purchase
    self.save
  end
  
  def has_product(product: nil)
    if self.purchases.select {|p| p.product_link == product["_links"]["self"]["href"]}.first
      true
    else
      false
    end
  end
  
  def reset_purchases
    accts = self.purchases.collect {|p| p.account_link}
    self.purchases.all.delete
    accts
  end
  
  # This event is used to show a connection between a Kiwi and a Party
  
  def id_kiwi_event
    {
      event: "kiwi_identity",
      ref: [
        {
          link: self.party_url,
          ref: "party"
        },
        {
          ref: :sub,
          id: self.user_proxy["id_token"]["sub"] 
        },
        {
          link: url_helpers.kiwi_url(self, host: Setting.services(:self, :host)),
          ref: "kiwi"
        }
      ],
      id_token: {
        sub: self.user_proxy["id_token"]["sub"]
      }
    }
  end
  
end
