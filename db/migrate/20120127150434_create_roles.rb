class CreateRoles < ActiveRecord::Migration
  def up
    create_table :roles do |t|
      t.string :name
      t.text :description
      t.string :default_path, :default => '/'
      t.boolean :locked, :default => false
    end
  end

  def down
    drop_table :roles
  end
end