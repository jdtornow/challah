module Auth
  # Random string class, uses ActiveSupport's SecureRandom if possible, otherwise gives a fairly 
  # secure random string
  class Random
    def self.token(length = 30)      
      return SecureRandom.hex(length/2) if defined?(::SecureRandom)

      c = [(0..9),('a'..'z'),('A'..'Z')].map {|i| i.to_a }.flatten
      (1..length).map{ c[rand(c.length)] }.join
    end
  end
end