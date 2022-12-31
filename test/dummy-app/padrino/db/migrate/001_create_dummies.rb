class CreateDummies < ActiveRecord::Migration
  def self.up
    create_table :dummies do |t|
      t.string :field
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :dummies
  end
end
