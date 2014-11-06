class UserProxy
  
  include Wisper::Publisher
  
  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :name, type: String
  field :email, type: String
  field :email_verified, type: Boolean
  field :access_token, type: Hash
  field :id_token, type: Hash
  
  belongs_to :kiwi
  
  def self.set_up_user(access_token: nil, id_token: nil)
    user = get_user_from_id_service(access_token: access_token)
    proxy = self.find_or_create(id_token: id_token, access_token: access_token)
    proxy
  end
  
  def self.find_or_create(id_token: nil, access_token: nil)
    up = self.where(name: id_token["preferred_username"]).first
    if up
      up.add_attrs(id_token: id_token, access_token: access_token)
    else
      up = self.new.add_attrs(id_token: id_token, access_token: access_token)
    end
    up
  end
    
  def self.get_user_from_id_service(access_token: nil)
    conn = Faraday.new(url: Setting.oauth["id_userinfo_service_url"])    
    conn.params = {access_code: access_token["access_code"]} 
    conn.authorization :Bearer, access_token["access_code"]
    resp = conn.get
    raise if resp.status >= 300
    JSON.parse(resp.body)
  end
    
  
  def add_attrs(id_token: nil, access_token: nil)
    raise if !id_token
    name = "preferred_username"
    email = "email_verified"
    key = :id_token
    self.name = id_token["preferred_username"]
    self.email_verified = id_token["email_verified"]
    self.email = id_token["email"]    
    self.access_token = access_token
    self.id_token = id_token
    save
    self
  end
    
  def has_a_kiwi?
    self.kiwi ? true : false
  end
  
end