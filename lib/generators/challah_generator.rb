require "rails/generators/active_record"

class ChallahGenerator < Rails::Generators::Base

  include ActiveRecord::Generators::Migration

  source_root File.expand_path("../templates", __FILE__)

  def copy_migration
    migration_template "migration.rb", "db/migrate/challah_create_users.rb", migration_version: migration_version
  end

  def migration_version
    "[#{ Rails::VERSION::MAJOR }.#{ Rails::VERSION::MINOR }]"
  end

end
