module Challah
  module UserStatusable
    extend ActiveSupport::Concern

    included do
      begin
        if columns.map(&:name).include?("status")
          enum status: %w( active inactive )
        end
      rescue ActiveRecord::StatementInvalid => exception
        raise exception unless exception.message =~ /could not find table/i ||
                               exception.message =~ /does not exist/i
      end
    end

    # Fallback to pre-enum active column (pre challah 1.4)
    def active=(enabled)
      if self.class.columns.map(&:name).include?("status")
        self.status = (!!enabled ? :active : :inactive)
      else
        write_attribute(:active, !!enabled)
      end
    end

    def active?
      # enum-based status
      if self.class.columns.map(&:name).include?("status")
        read_attribute(:status).to_s == "active"

      # support for non-enum status column (pre challah 1.4)
      else
        !!read_attribute(:active)
      end
    end
    alias_method :active, :active?

    def valid_session?
      active?
    end
  end
end
