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
    self.create_links(party: create_party.party)
    self.save
    publish(:successful_save_event, self)
  end
  
  def update_me(cust: nil, current_user_proxy: nil)
    raise if self.user_proxy != current_user_proxy
    self.update_attrs(cust: cust, current_user_proxy: current_user_proxy )
    party = CustomerPort.new.update_customer(customer: self, party_url: self.party_url) if (cust.keys & ["name", "age"]).present?
    self.save
    publish(:successful_save_event, self)
  end
  
  
  def update_attrs(cust: nil, current_user_proxy: nil)
    raise if current_user_proxy.nil?
    self.name = cust[:name]
    self.age = cust[:age]
    self.twitter_handle = cust[:twitter_handle]
    self.user_proxy = current_user_proxy if self.user_proxy != current_user_proxy # this has some bizzare behaviour that causes the proxy to be deleted
    # k = Kiwi.first; k.user_proxy = @current_user_proxy; k.save
  end
  
  def create_party 
    CustomerPort.new.create_new_customer(customer: self)
  end
  
  def check_party
    resp = CustomerPort.new.get_customer(party_url: self.party_url)
    if resp.status == :ok
      self.create_links(party: resp.party)
      self.name = resp.party["party"]["name"] if self.name != resp.party["party"]["name"]
      self.age = resp.party["party"]["age"] if self.age != resp.party["party"]["age"]
      self.save
    elsif resp.status == :not_found
      self.create_links(party: create_party())
    elsif resp.status == :unavailable
    end
  end
  
  def create_links(party: nil)
    party["_links"].each do |rel, link|
      if rel == "self"
        self.party_url = link["href"]
      else
        self.add_link_refs(rel: rel, link: link["href"])
      end
    end
    self.save
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
  
  def get_purchase(product: nil)
    @purchase = self.purchases.select {|p| p.product_link == product["_links"]["self"]["href"]}.first
  end
    
  def reset_purchases
    buys = self.purchases.collect {|p| p.origination_link}
    self.purchases.all.delete
    buys
  end
  
  # This event is used to show a connection between a Kiwi and a Party
  
  def id_kiwi_event
    {
      event: "kiwi_identity",
      timestamps: {
        identity_validation_time: Time.now
      },
      party: {
        _links: {
          self: {
            href: self.party_url
          }
        }        
      },
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
