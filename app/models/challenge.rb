class Challenge
  include Mongoid::Document
  include Mongoid::Timestamps

  field :verifier, :type => String
  field :challenge, :type => String


  def self.make(verifier: nil, challenge: nil)
    model = self.first
    model ? ch = model : ch = self.new
    ch.update_it(verifier: verifier, challenge: challenge)
    ch
  end

  def self.code_verifier
    self.first.verifier
  end

  def update_it(verifier: nil, challenge: nil)
    self.verifier = verifier
    self.challenge = challenge
    save
    self
  end

end
