require 'csv'
namespace :seed do

  task :transfer_to_oro => :environment do
    # pull the purchase order, sanitize the lines, and push
    l = LightApi.last
    o = OroApi.last
    l.refresh_token
    po = l.purchase_order(id: "5")
    payload = Orodoro::Modificator::SetItemPayload.call(po, l)

    # oro_payload = OroApi.create_sales_order_payload(lines: payload).as_json
    oro_order = o.create_sales_order(lines: payload)
    binding.pry
  end

  task :create_po => :environment do
    # test purchase order behavior with the seeded products
    l = LightApi.last
    l.refresh_token
    products = l.get_products
    po = l.create_purchase_order(shop_id: "1")
    products["Item"].each do |product|
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
      puts "__________________________"
      puts order_line
      puts "__________________________"
    end
  end

  task :seed_products => :environment do
    # Seed the products from a csv exported from Orodoro. Only used for testing purposes
    l = LightApi.last
    l.refresh_token
    CSV.foreach("lib/tasks/seed_products.csv", headers: true) do |x|
      product = l.create_product_simple(
        name: x["Description"],
        upc: x["SKU"],
        sku: x["SKU"],
        wholesale_cost: x["avg cost"].to_i == 0 ? "10" : x["avg cost"].to_s,
        cost: x["avg cost"].to_i == 0 ? "15" : x["avg cost"].to_s
      )
      binding.pry
      if product["httpCode"]
        sleep 15
        l.refresh_token
        product = l.create_product_simple(
          name: x["Description"],
          upc: x["SKU"],
          sku: x["SKU"],
          wholesale_cost: x["avg cost"].to_i == 0 ? "10" : x["avg cost"].to_s,
          cost: x["avg cost"].to_i == 0 ? "15" : x["avg cost"].to_s
        )
      end
      puts "_____________________"
      puts product
      puts "____________________"
    end
  end

  task :auth_lightspeed => :environment do
    # Use the following link to generate a code.
    # Be mindful that you have to do within like 5 seconds or it fails so quickly copy and paste and run
    # https://cloud.lightspeedapp.com/oauth/authorize.php?response_type=code&client_id=client_id&scope=employee:all
    light_api = LightApi.new(
      client_id: "client_id",
      client_secret: "client_secret",
      account: "account number"
    )
    response = light_api.authorize_light(code: "<YOUR CODE FROM ABOVE LINK HERE>")
    light_api.update!(refresh: response["refresh_token"], light_key: response["access_token"])

    puts "___________________________"
    puts light_api.as_json
    puts "____________________________"
  end

  task :auth_oro => :environment do
    client_id = "client_id"
    client_secret = "client_idX"
    new_oro = OroApi.new(client_id: client_id, client_secret: client_secret)
  end
end
