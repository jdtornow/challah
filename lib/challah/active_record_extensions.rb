module Challah
  # Included for backwards compatibility. These methods are deprecated
  # and will be removed in future versions
  module ActiveRecordExtensions
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    module ClassMethods
      def challah_user
        ActiveSupport::Deprecation.warn("#{ self.to_s }.challah_user is deprecated and will be removed in future versions, use `include Challah::Userable` instead")
        self.send(:include, Challah::Userable)
      end
    end
  end
end
