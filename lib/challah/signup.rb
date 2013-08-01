module Challah
  class Signup
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    attr_reader :errors
    attr_accessor :provider, :user

    def initialize(attributes = {})
      self.user = Challah.user.new
      self.provider = :password
      self.attributes = attributes
      @errors = []
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
      @provider = :password unless value.to_s.blank?
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
      @errors = ActiveModel::Errors.new(user)

      result = true

      unless user.valid?
        result = false
        user.errors.each { |a, e| @errors.add(a, e) }
      end

      if !provider or !valid_provider?
        result = false
        user.errors.each { |a, e| @errors.add(a, e) unless @errors.added?(a, e) }
      end

      result
    end

    def self.model_name
      ActiveModel::Name.new(Challah::Signup, Challah, "Signup")
    end
  end
end