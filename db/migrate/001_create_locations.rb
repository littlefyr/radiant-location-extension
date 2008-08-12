class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :name, :full_address, :website_url, :page_path, :group
      t.float :lat, :lng
      t.boolean :manual_geocode, :default => 0
      t.timestamps
      t.integer :lock_version, :created_by_id, :updated_by_id
    end
  end

  def self.down
    drop_table :locations
  end
end
