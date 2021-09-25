class CreateOroApis < ActiveRecord::Migration[6.0]
  def change
    create_table :oro_apis do |t|
      t.string :client_id
      t.string :client_secret
      t.string :oro_key
      t.string :refresh_key
      t.string :merchant_id
      t.timestamps
    end
  end
end
