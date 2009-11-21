class ChangesToMyModel2so2yd < ActiveRecord::Migration

  def self.up
    add_column :my_models, :address, :string
    change_column :my_models, :name, :string, :limit => 40
  end

  def self.down
    remove_column :my_models, :address
    change_column :my_models, :name, :string
  end

end