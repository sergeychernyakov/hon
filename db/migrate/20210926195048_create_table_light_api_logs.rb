class CreateTableLightApiLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :light_api_logs do |t|
      t.string :light_api_entity_id
      t.string :entity_type
      t.string :light_api_client_id
      t.string :oro_api_client_id
      t.text :contents
      t.text :payload
      t.text :response
      t.boolean :sent_to_orodoro, default: true
      t.boolean :is_failed, default: false
      t.string :event
    end
  end
end
