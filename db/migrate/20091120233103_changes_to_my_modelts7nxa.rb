class ChangesToMyModelts7nxa < ActiveRecord::Migration

  def self.up
    change_column :my_models, :name, :string, :limit => 40
  end

  def self.down
    change_column :my_models, :name, :string
  end

end