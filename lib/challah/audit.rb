module Challah
  # The audit methods are included into ActiveRecord::Base automatically and add
  # basic audit trail functionality for your models. Certain columns will be
  # updated with the current user's id if provided at save time.
  #
  # For new records, the following fields will be updated if +current_user+ is provided:
  #
  # * created_by
  # * created_user_id
  #
  # For updating existing records, the following attributes will be updated:
  #
  # * updated_by
  # * modified_by
  # * updated_user_id
  #
  # To save the user id that changed a record, just set the +current_user+ attribute of the
  # model in your controller. For example:
  #
  #     class WidgetsController < ApplicationController
  #       ...
  #
  #       def update
  #         @widget = Widget.find(params[:id])
  #         @widget.current_user = current_user
  #         @widget.update_attributes(params[:widget])
  #         ...
  #       end
  #
  module Audit
    extend ActiveSupport::Concern

    included do
      before_save :before_save_audit
    end

    # @private
    def initialize_dup(other)
      clear_audit_attributes
    end

    def current_user=(value)
      @current_user_id = (Object === value ? value[:id] : value)
    end

    def current_user_id=(value)
      @current_user_id = value
    end

    def current_user_id
      unless @current_user_id
        @current_user_id = 0
      end

      @current_user_id
    end

    private

    def before_save_audit
      if new_record?
        all_audit_attributes.map(&:to_s).each do |column|
          if respond_to?(column) && respond_to?("#{ column }=")
            write_attribute(column, current_user_id)
          end
        end
      else
        audit_attributes_for_update.map(&:to_s).each do |column|
          if respond_to?(column) && respond_to?("#{ column }=")
            next if attribute_changed?(column) # don't update the column if we already manually did
            write_attribute(column, current_user_id)
          end
        end
      end
    end

    # @private
    def audit_attributes_for_update
      [ :updated_by, :modifed_by, :updated_user_id ]
    end

    # @private
    def audit_attributes_for_create
      [ :created_by, :created_user_id ]
    end

    # @private
    def all_audit_attributes
      audit_attributes_for_update + audit_attributes_for_create
    end

    # Clear attributes and changed_attributes
    def clear_audit_attributes
      all_audit_attributes.each do |attribute_name|
        if respond_to?(attribute_name) && respond_to?("#{ attribute_name }=")
          write_attribute(attribute_name, nil)
        end

        changed_attributes.delete(attribute_name)
      end
    end
  end
end
