require 'digest/sha2'
require 'bcrypt'

module Auth  
  # Handles all encryption, hashing and comparison necessary for tokens and passwords.
  class Encrypter
    class << self
      BCRYPT_COST = 10
      
      attr_accessor :stretches, :joiner
      
      # The number of times to hash the given password.
      def stretches
        @stretches ||= 20
      end
      
      # Used to join multiple parameters for a given encrypt command.
      def joiner
        @joiner ||= "|"
      end
      
      # Passwords and secure objects are encrypted (hashed) in a one-way technique. This way
      # any item stored in the database can never be reversed into an actual password.
      def hash(*tokens)
        result = tokens.flatten.join(joiner)
        stretches.times { result = Digest::SHA512.hexdigest(result) }
        result
      end
      
      def md5(*tokens)
        Digest::MD5.hexdigest(tokens.flatten.join(joiner))
      end
      
      def bcrypt(secret)
        BCrypt::Password.create(secret, :cost => BCRYPT_COST)
      end
      
      # Returns true if the the bcrypted value of a is equal to b
      def bcrypt_compare(a, b)
        !!(BCrypt::Password.new(a) == b)
      rescue BCrypt::Errors::InvalidHash
        false
      end
    end
  end
end