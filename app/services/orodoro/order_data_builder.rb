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
    return if purchase_order_obj["OrderLines"].blank?

    @payload = Orodoro::Modificator::SetItemPayload.call(purchase_order_obj, light_api)
  end

end
