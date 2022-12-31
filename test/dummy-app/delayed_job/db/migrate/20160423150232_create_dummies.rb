class CreateDummies < ActiveRecord::Migration
  def change
    create_table :dummies do |t|
      t.string :field
      t.timestamps null: false
    end
  end
end
