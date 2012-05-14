module Challah
  # Random string class, uses ActiveSupport's SecureRandom if possible, otherwise gives a fairly
  # secure random string
  class Random
    # Returns a random string for use as a token at the given length.
    def self.token(length = 30)
      return SecureRandom.hex(length/2) if secure_random?

      c = [(0..9),('a'..'z'),('A'..'Z')].map {|i| i.to_a }.flatten
      (1..length).map{ c[rand(c.length)] }.join
    end

    # Is ActiveSupport::SecureRandom available. If so, we'll use it.
    def self.secure_random?
      defined?(::SecureRandom)
    end
  end
end