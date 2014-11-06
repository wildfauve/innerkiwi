class Kiwi
  
  include Wisper::Publisher

  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, type: String
  field :age, type: Integer
  field :twitter_handle, type: String
  field :party_url, type: String
  
  has_one :user_proxy, autosave: true
  
  def create_me(cust: nil, current_user_proxy: nil)
    raise if !current_user_proxy
    self.name = cust[:name]
    self.age = cust[:age]
    self.twitter_handle = cust[:twitter_handle]
    self.user_proxy = current_user_proxy
    party = CustomerPort.new.create_new_customer(self)
    self.party_url = party["_links"]["self"]["href"]
    self.save
    publish(:successful_save_event, self)
  end
  
  def check_party
    party = CustomerPort.new.get_customer(url: self.party_url)
    self.name = party["party"]["name"] if self.name != party["party"]["name"]
    self.age = party["party"]["age"] if self.age != party["party"]["age"]
    self.save
  end
  
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
        }
      ],
      id_token: {
        sub: self.user_proxy["id_token"]["sub"]
      }
    }
  end
  
end
