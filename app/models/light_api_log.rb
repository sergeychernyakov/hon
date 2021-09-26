class LightApiLog < ApplicationRecord
	CREATE_EVENT = 'create'
	DESTROY_EVENT = 'destroy'
	PURCHASE_ORDER_ENTITY_TYPE = 'PurchaseOrder'

	def self.synced_already?(entity_id, entity_type, light_api_client_id, oro_api_client_id)
		find_by(light_api_entity_id: entity_id, entity_type: entity_type, event: CREATE_EVENT, light_api_client_id: light_api_client_id, oro_api_client_id: oro_api_client_id)
	end
end