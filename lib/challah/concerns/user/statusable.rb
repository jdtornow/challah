module Challah
  module UserStatusable

    extend ActiveSupport::Concern

    included do
      begin
        if columns.map(&:name).include?("status")
          additional_statuses = Array(Challah.options[:additional_statuses])

          # for >= Rails 7.1, use positional argument enum syntax
          if Gem.loaded_specs["activerecord"].version >= Gem::Version.create("7.1")
            enum :status, [ :active, :inactive, *additional_statuses ].map(&:to_sym)
          else
            enum status: [ :active, :inactive, *additional_statuses ].map(&:to_sym)
          end
        end
      rescue ActiveRecord::StatementInvalid => exception
        raise exception unless exception.message =~ /could not find table/i ||
                               exception.message =~ /does not exist/i
      end
    end

    def active
      active?
    end

    def valid_session?
      active?
    end

  end
end
