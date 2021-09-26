class Orodoro::OrdersSyncer
  class << self
    def sync_all
      LightApi.all.each do |light_api|
        oro_api = light_api.oro_api || OroApi.last
        next if oro_api.blank?

        Orodoro::OrdersSyncer.new(light_api, oro_api).sync
        puts "All light API accounts synced"
      end
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
    puts "Light API ID: #{light_api.id} Synced properly"
  end

  def refresh_light_api_token
    light_api.refresh_token
  end

  def sync_orders
    light_api.purchase_orders_ready_for_oro.each do |purchase_order_obj|      
      order_id = purchase_order_obj["orderID"]
      payload = Orodoro::OrderDataBuilder.new(light_api, purchase_order_obj).build
      oro_order = oro_api.create_sales_order(lines: payload, order_id: order_id)
      light_api.update_po_oro_completed(id: order_id) #mark oro_completed custom field

      "Order ID: #{order_id} Created successfully on ORO side"
    end
  end

end
