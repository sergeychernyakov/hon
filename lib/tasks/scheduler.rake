desc "This task is called by the Heroku scheduler add-on"

task :create_lightspeed_purchase_order => :environment do
  puts "Creating test Lightspeed Purchase Order"
  l = LightApi.last
  l.refresh_token
  products = l.get_products
  po = l.create_purchase_order(shop_id: "1")

  products["Item"].last do |product|
    order_line = l.create_order_line_item(
      quantity: "3",
      price: product["defaultCost"],
      product_id: product["itemID"],
      order_id: po["Order"]["orderID"]
    )
    if order_line["httpCode"]
      sleep 15
      l.refresh_token
      order_line = l.create_order_line_item(
        quantity: "3",
        price: product["defaultCost"],
        product_id: product["itemID"],
        order_id: po["Order"]["orderID"]
    )
    end
  end

  puts "done."
end

task :transfer_purchased_orders_to_orodoro => :environment do
  puts "Creating test Purchase Order"
  l = LightApi.all.each do |light_api|
    oro_api = light_api.oro_api || OroApi.last
    next if oro_api.blank?

    light_api.refresh_token
    light_api.purchase_orders_ready_for_oro.each do |po|
      order_id = po["orderID"]
      items = po["OrderLines"]["OrderLine"]
      item_ids = items.pluck("itemID")

      payload = light_api.get_item_payload(ids: item_ids, shop_id: "1").select { |x| x["shop"] == "1" }
      payload.each do |p|
        p["quantity"] = items.find {|x| x["itemID"] == p["item"] }["quantity"].to_i
      end
      oro_order = oro_api.create_sales_order(lines: payload, order_id: order_id)

      light_api.update_po_oro_completed(id: order_id) #mark oro_completed custom field

      "Order ID: #{order_id} Created successfully on ORO side"
    end

    puts "Light API ID: #{light_api.id} Synced properly"

  end
  puts "All Light API accounts synced"
end
