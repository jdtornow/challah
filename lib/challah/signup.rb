module Challah
  class Signup
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    attr_reader :errors

    def initialize(attributes = {})
      self.user = ::User.new
      self.attributes = attributes
      @errors = []
    end
  end
end