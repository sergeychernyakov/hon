ActiveAdmin.register LightApiLog do
  actions :index, :show

  permit_params :light_api_entity_id, :entity_type, :light_api_client_id, :oro_api_client_id, :contents, :payload, :response, :sent_to_orodoro, :is_failed, :event

  index do
    id_column
    column :light_api_entity_id
    column :entity_type
   
    column :light_api_client_id
    column :oro_api_client_id
    column :contents
    column :sent_to_orodoro
    column :is_failed
    actions
  end
  
end
