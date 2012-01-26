module Auth
  module BigBrother
    def self.included(base)
      base.class_eval do
        before_save :before_save_big_brother
      end
    end   
    
    # @private
    def initialize_dup(other)
      clear_big_brother_attributes
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
      def before_save_big_brother
        if new_record?
          all_big_brother_attributes.each do |attr_name|
            attr_name = attr_name.to_s
            column = column_for_attribute(attr_name)

            if column || @attributes.has_key?(attr_name)
              write_attribute(attr_name, current_user_id)
            end     
          end
        else
          big_brother_attributes_for_update.each do |column|
            if respond_to?(column) && respond_to?("#{column}=")
              column = column.to_s
              next if attribute_changed?(column)
              write_attribute(column, current_user_id)
            end
          end
        end
      end
      
      # @private
      def big_brother_attributes_for_update
        [ :updated_by, :modifed_by, :updated_user_id ]
      end
      
      # @private
      def big_brother_attributes_for_create
        [ :created_by, :created_user_id ]
      end
      
      # @private
      def all_big_brother_attributes
        big_brother_attributes_for_update + big_brother_attributes_for_create
      end
      
      # Clear attributes and changed_attributes
      def clear_big_brother_attributes
        all_big_brother_attributes.each do |attribute_name|
          self[attribute_name] = nil
          changed_attributes.delete(attribute_name)
        end
      end
  end
end