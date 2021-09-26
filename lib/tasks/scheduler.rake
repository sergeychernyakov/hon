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
  Orodoro::OrdersSyncer.sync_all
end
