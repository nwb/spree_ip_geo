class CreateSpreeIpMappings < ActiveRecord::Migration
  def self.up
    create_table :spree_ip_mappings do |t|
      t.string :ip_address
      t.string :iso
      t.string :state
      t.string :city
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :spree_ip_mappings
  end
end
