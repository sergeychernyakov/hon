class Orodoro::OrdersSyncer
  class << self
    def sync_all
      LightApi.active.each do |light_api|
        oro_api = light_api.oro_api || OroApi.last
        next if oro_api.blank?

        Orodoro::OrdersSyncer.new(light_api, oro_api).sync
        puts "Light API ID: #{light_api.id} Synced properly"
      end
      puts "All light API accounts synced"
    end
  end # class << self

  def initialize(light_api, oro_api)
    @light_api = light_api
    @oro_api = oro_api
  end

  attr_reader :light_api, :oro_api

  def sync
    refresh_light_api_token
    sync_orders
  end

  def refresh_light_api_token
    light_api.refresh_token
  end

  def sync_orders
    light_api.purchase_orders_ready_for_oro.each do |purchase_order_obj|      
      order_id = purchase_order_obj["orderID"]
      next if LightApiLog.synced_already?(order_id, LightApiLog::PURCHASE_ORDER_ENTITY_TYPE, light_api.client_id, oro_api.client_id)

      payload = Orodoro::OrderDataBuilder.new(light_api, purchase_order_obj).build
      oro_order = oro_api.create_sales_order(lines: payload, order_id: order_id, account_id: light_api.account)
      is_failed = oro_order["error_message"].present?
      light_api.update_po_oro_completed(id: order_id) unless is_failed #mark oro_completed custom field
      LightApiLog.cleanup_already_failed_log(order_id, LightApiLog::PURCHASE_ORDER_ENTITY_TYPE, light_api.client_id, oro_api.client_id) if is_failed

      Orodoro::Logger.new(
        light_api_client_id: light_api.client_id, oro_api_client_id: oro_api.client_id, entity_type: LightApiLog::PURCHASE_ORDER_ENTITY_TYPE, 
        light_api_entity_id: order_id, payload: payload.to_json, response: oro_order.to_json, event: LightApiLog::CREATE_EVENT, is_failed: is_failed, sent_to_orodoro: !is_failed
      ).log!

      puts "Order ID: #{order_id} #{is_failed ? 'failed' : 'Created successfully'} on ORO side"
    end
  end

end
