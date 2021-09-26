class Orodoro::OrderDataBuilder

  def initialize(light_api, purchase_order_obj)
    @light_api = light_api
    @purchase_order_obj = purchase_order_obj
    @payload = {}
  end

  attr_reader :light_api, :purchase_order_obj

  def build
    build_order_payload
    @payload
  end

  private

  def build_order_payload
    items = purchase_order_obj["OrderLines"]["OrderLine"]
    item_ids = items.pluck("itemID")

    @payload = light_api.get_item_payload(ids: item_ids, shop_id: light_api.default_shop_id).select { |x| x["shop"] == light_api.default_shop_id }
    @payload.each do |p|
      p["quantity"] = items.find {|x| x["itemID"] == p["item"] }["quantity"].to_i
    end
  end

end
