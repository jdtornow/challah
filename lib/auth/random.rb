module Auth
  # Random string class, uses ActiveSupport's SecureRandom if possible, otherwise gives a fairly 
  # secure random string
  class Random
    def self.token(length = 30)
      if defined?(::SecureRandom)
        SecureRandom.hex(length/2)
      else
        c = [(0..9),('a'..'z'),('A'..'Z')].map {|i| i.to_a }.flatten
        (0..length).map{ c[rand(c.length)] }.join
      end
    end
  end
end