require 'digest/sha2'
require 'bcrypt'

module Challah
  # Handles all encryption, hashing and comparison necessary for tokens and passwords.
  class Encrypter
    attr_accessor :cost, :joiner

    # The number of times to hash the given password.
    def cost
      @cost ||= 10
    end

    # Used to join multiple parameters for a given encrypt command.
    def joiner
      @joiner ||= "|"
    end

    # Passwords and secure objects are encrypted (hashed) in a one-way technique. This way
    # any item stored in the database can never be reversed into an actual password.
    def hash(*tokens)
      result = tokens.flatten.join(joiner)
      cost.times { result = Digest::SHA512.hexdigest(result) }
      result
    end

    def md5(*tokens)
      Digest::MD5.hexdigest(tokens.flatten.join(joiner))
    end

    def encrypt(secret)
      BCrypt::Password.create(secret, cost: cost)
    end

    # Returns true if the the bcrypted value of a is equal to b
    def compare(crypted_string, plain_string)
      BCrypt::Password.new(crypted_string).is_password?(plain_string)
    rescue BCrypt::Errors::InvalidHash
      false
    end

    def self.compare(*args)
      new().compare(*args)
    end

    def self.encrypt(*args)
      new().encrypt(*args)
    end

    def self.hash(*args)
      new().hash(*args)
    end

    def self.md5(*args)
      new().md5(*args)
    end
  end
end
