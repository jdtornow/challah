module Challah
  module UserStatusable

    extend ActiveSupport::Concern

    included do
      begin
        if columns.map(&:name).include?("status")
          additional_statuses = Array(Challah.options[:additional_statuses])
          enum status: [ :active, :inactive, *additional_statuses ].map(&:to_sym)
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
