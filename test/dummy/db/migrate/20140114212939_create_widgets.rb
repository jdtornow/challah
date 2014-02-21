class CreateWidgets < ActiveRecord::Migration
  def change

    # Widgets are used as a content model for testing only.

    create_table :widgets do |t|

      # widget-specific attributes
      t.string :title
      t.string :short_title
      t.integer :image_id

      t.string :format, default: "markdown"
      t.text :content

      # optional attributes that will be set if they exist
      t.string :full_path, limit: 1000

      # Standard model attributes
      t.integer :site_id
      t.integer :entry_id
      t.integer :revision
      t.string :status, default: 'draft'
      t.integer :category_id
      t.datetime :published_at, :archived_at
      t.integer :created_by, :updated_by, default: 0
      t.integer :published_by, :archived_by, default: 0
      t.timestamps

    end
  end
end
