require 'csv'
namespace :seed do

  task :transfer_to_oro => :environment do
    # pull the purchase order, sanitize the lines, and push
    l = LightApi.last
    o = OroApi.last
    l.refresh_token
    po = l.purchase_order(id: "5")
    # binding.pry
    items = po["Order"]["OrderLines"]["OrderLine"]
    item_ids = items.pluck("itemID")
    payload = l.get_item_payload(ids: item_ids, shop_id: "1").select { |x| x["shop"] == "1" }
    
    payload.each do |p|
      p["quantity"] = items.find {|x| x["itemID"] == p["item"] }["quantity"].to_i
    end
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
    # https://cloud.lightspeedapp.com/oauth/authorize.php?response_type=code&client_id=c8524d364313825929e634de4874806a4499dd7979908b34b07b4d960c01a722&scope=employee:all
    light_api = LightApi.new(
      client_id: "c8524d364313825929e634de4874806a4499dd7979908b34b07b4d960c01a722",
      client_secret: "00c9e67b895f42666ed41375732e3c41a9930d1cc67150407ba1097662c5a236",
      account: "261144"
    )
    response = light_api.authorize_light(code: "<YOUR CODE FROM ABOVE LINK HERE>")
    light_api.update!(refresh: response["refresh_token"], light_key: response["access_token"])

    puts "___________________________"
    puts light_api.as_json
    puts "____________________________"
  end

  task :auth_oro => :environment do
    client_id = "vRpko+Zuwv23oxS/RLgqFqdMa/TXzaH9C5LFXTm/"
    client_secret = "cei8EdCuExY9ukb9CG1nAhGaNjNcFWZrmZ3N4dIX"
    new_oro = OroApi.new(client_id: client_id, client_secret: client_secret)
  end
end
