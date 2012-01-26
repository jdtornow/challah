module Auth
  module Authable
    module User
      def self.included(base)
        base.extend(AuthableMethods)
      end
    
      module AuthableMethods
        def authable_user
          unless included_modules.include?(InstanceMethods)
            include InstanceMethods
          end
          
          class_eval do
            validates_presence_of :first_name, :last_name, :email, :role_id, :username
            validates_uniqueness_of :email, :username
            validate :validate_new_password
            
            before_save :before_save_password
          
            belongs_to :role
            has_many :permission_users, :dependent => :destroy
            has_many :permissions, :through => :permission_users, :order => 'permissions.name'
          
            scope :active, where(:active => true).order('users.first_name, users.last_name')
            scope :inactive, where(:active => false).order('users.first_name, users.last_name')
            scope :with_role, lambda { |role| where([ "users.role_id = ?", role ]) }
            scope :search, lambda { |q| where([ 'users.first_name like ? OR users.last_name like ? OR users.email like ? OR users.username LIKE ?', "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%" ]) }
          
            after_save :save_permission_keys
          end
        end
      
        # Instance methods to be included once authable_user is set up.
        module InstanceMethods
          # full name
          def name
            "#{first_name} #{last_name}"
          end

          # shortened name, just includes the first name and last initial
          def small_name
            "#{first_name.to_s.titleize} #{last_name.to_s.first.upcase}."
          end
          
          # The default url where this user should be redirected to after logging in. Also can be used as the main link
          # at the top of navigation.
          def default_path
            role ? role.default_path : '/'
          end
          
          # Returns true if this user is active, and should be able to log in
          # Reserved for future use, turn this to false to disable access for this user.
          # TODO: make a user inactive after a certain number of failed login attempts
          def active?
            !!self.active
          end
          
          # Is this user able to be deleted from the database? This defaults
          # to allow deletion of all users (except the last one in the db), 
          # but you can override this method in your app to check specific 
          # criteria before deleting a user.
          def deleteable?
            self.class.all.count > 1
          end
          
          # Update a user's own account. This differsfrom User#update_attributes because it won't let
          # a user update their own role and other protected elements. 
          #
          # All attributes on the user model can be updated, except for the ones listed below.
          def update_account_attributes(attributes = {})
            invalid_attributes = %w(
              api_key
              created_by
              crypted_password
              failed_login_count
              id
              last_login_at
              login_count
              permissions
              permissions_attributes
              permission_users
              permission_users_attributes
              persistence_token
              role_id
              updated_by
              ).collect { |s| s.to_sym }
            
            attributes = attributes.symbolize_keys
            
            attributes.keys.each do |a|
              attributes.delete(a) if invalid_attributes.include?(a)
            end
            
            self.update_attributes(attributes)
          end
          
          # Get the value of the current password, only can be used right after setting a new password.
          def password
            @password
          end

          # Set a password for this user
          def password=(value)
            if value.to_s.blank?
              @password = nil
              @password_updated = false
            else
              @password = value
              @password_updated = true
            end
          end

          def password_confirmation=(value)
            @password_confirmation = value
          end

          # Use this method to authenticate this user based on the given password. Returns true 
          # if the password provided is this user's current password.
          #
          # You can override this method if you want to use a different, non-bcrypt password 
          # based authentication method.
          def authenticate(plain_password)
            return false unless active?
            authenticate_with_password(plain_password)
          end
          
          # Returns the permission keys used by this specific user, does not include any role-based permissions. 
          def user_permission_keys
            @user_permission_keys ||= self.permissions(true).collect(&:key)
          end

          # Returns the permission keys in an array for exactly what this user can access. This includes all role based permission keys, and any specifically given to this user through permissions_users
          def permission_keys
            unless @permission_keys
              role_keys = self.role ? self.role.permission_keys.clone : []
              user_keys = new_record? ? [] : self.user_permission_keys.clone

              @permission_keys = (role_keys + user_keys).uniq
            end

            @permission_keys
          end

          # Set the permission keys that this role can access
          def permission_keys=(value)
            @permission_keys = value
            @permission_keys
          end

          # When a role is set, reset the permission_keys
          def role_id=(value) #:nodoc:
            @permission_keys = nil    
            self[:role_id] = value
          end

          # Returns true if this user has permission to the provided permission key
          def permission?(key)
            permission_keys.include?(key.to_s)
          end
          alias :has :permission?

          # Allow dynamic checking for permissions
          # 
          # Example:
          #   def admin?
          #     has(:admin)
          #   end
          def method_missing(sym, *args, &block)
            return has(sym.to_s.gsub(/\?/, '')) if sym.to_s =~ /^[a-z_]*\?$/
            super(sym, *args, &block)
          end
          
          protected
            # Called after_save
            #
            # Saves any updated permission keys to the database for this user.  
            # Any permission keys that are specifically given to this user and are also in the 
            # user's role will be removed. So, the only permission keys added here will be those 
            # in addition to the user's role.
            def save_permission_keys
              if @permission_keys and Array === @permission_keys
                self.permission_users(true).clear

                @permission_keys = @permission_keys.uniq - self.role.permission_keys

                @permission_keys.each do |key|
                  permission = ::Permission.find_by_key(key)

                  if permission
                    self.permission_users.create(:permission_id => permission.id, :user_id => self.id)
                  end
                end

                @permission_keys = nil
                @user_permission_keys = nil

                self.permissions(true).collect(&:key)
              end
            end
          
            # called before_save on the User model, actually encrypts the password with a new generated salt
            def before_save_password
              if @password_updated and valid?
                self.crypted_password = ::Auth::Encrypter.bcrypt(@password)

                @password_updated = false
                @password = nil
              end

              self.persistence_token = ::Auth::Random.token(125) if self.persistence_token.to_s.blank?
              self.api_key = ::Auth::Random.token(25) if self.api_key.to_s.blank?
            end

            # validation call for new passwords, make sure the password is confirmed, and is >= 4 characters
            def validate_new_password
              if new_record? and self.read_attribute(:crypted_password).to_s.blank? and !@password_updated
                errors.add :password, :blank
              elsif @password_updated
                if @password.to_s.size < 4
                  errors.add :password, :invalid_password
                elsif @password.to_s != @password_confirmation.to_s
                  errors.add :password, :no_match_password
                end
              end
            end
          private
            def authenticate_with_password(plain_password)
              ::Auth::Encrypter.bcrypt_compare(self.crypted_password, plain_password)
            end
        end
      end
    end
  end
end