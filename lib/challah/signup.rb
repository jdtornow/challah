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
      @errors = ActiveModel::Errors.new(self)
    end

    def attributes=(value)
      return unless Hash === value

      value.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def method_missing(method, *attrs, &block)
      if user.respond_to?(method)
        return user.send(method, *attrs, &block)
      else
        super
      end
    end

    def name
      "Signup"
    end

    def password=(value)
      @provider = :password
    end

    def provider?
      Challah.providers.keys.include?(@provider)
    end

    def provider
      @provider ||= :password
    end

    def provider=(value)
      @provider = value.to_sym
    end

    def read_attribute_for_validation(attr)
      send(attr)
    end

    def save
      if valid?
        user.save
      end
    end

    def valid?
      if user.valid? and provider?
        true
      else
        @errors = ActiveModel::Errors.new(self)

        user.errors.messages.each do |k, v|
          v.each do |msg|
            @errors.add(k, msg)
          end
        end

        false
      end
    end

    class << self
      def human_attribute_name(attr, options = {})
        attr.to_s.humanize
      end

      def lookup_ancestors
        [ self ]
      end
    end
  end
end