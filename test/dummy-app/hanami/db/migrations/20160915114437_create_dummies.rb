Hanami::Model.migration do
  change do
    create_table :dummies do
      primary_key :id
      column :field, String
    end
  end
end
