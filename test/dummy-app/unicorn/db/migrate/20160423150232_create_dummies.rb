class CreateDummies < ActiveRecord::Migration[4.2]
  def change
    create_table :dummies do |t|
      t.string :field
      t.timestamps null: false
    end
  end
end
