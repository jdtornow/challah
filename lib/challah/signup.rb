module Challah
  class Signup
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    attr_reader :errors
    attr_accessor :provider, :user

    def initialize(attributes = {})
      self.user = ::User.new
      self.attributes = attributes
      self.provider = :password
    end

    def attributes=(value)
      return unless Hash === value

      value.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def method_missing(method, *attrs)
      user.send(method, *attrs)
    end

    def password=(value)
      @provider = :password
      user.password = value
    end

    def valid_provider?
      user.valid_provider?(provider)
    end

    def provider=(value)
      if value.respond_to?(:to_sym)
        @provider = value.to_sym
      else
        @provider = nil
      end
    end

    def save
      if valid?
        user.save
      else
        false
      end
    end

    def valid?
      if user.valid? and provider and valid_provider?
        true
      else
        @errors = user.errors.clone
        false
      end
    end
  end
end