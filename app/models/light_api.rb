class LightApi < ApplicationRecord
  include HTTParty

  def get_reconciles
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/InventoryCountReconcile.json", headers: headers).parsed_response
  end

  def create_reconcile(params)
    payload = {
      "inventoryCountID": params[:count_id]
    }
    self.class.post("https://api.lightspeedapp.com/API/Account/#{account}/InventoryCountReconcile.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def get_item_payload(params)
    items = []
     ids_to_params = "%5B%22" + params[:ids].compact.join("%22%2c%22") + "%22%5D"
     counter = 0
     while counter < 1000
       self.refresh_token
       sleep 3
       res = self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Item.json?offset=#{counter}&load_relations=%5B%22ItemShops%22%2c%22CustomFieldValues%22%5D&itemID=IN,#{ids_to_params}", headers: headers).parsed_response
       payload = res.dig("Item")
       if payload.nil? || payload.empty?
         break
       end
       if payload.class == Hash
         zz = [payload].map do |x|
           x.dig("ItemShops","ItemShop")
            .map do |z|
               {
                name: x["description"],
                item: z["itemID"],
                price: x["Prices"]["ItemPrice"].first["amount"].to_f,
                cost: x["defaultCost"].to_f,
                sku: x["manufacturerSku"],
                qoh: z["qoh"],
                shop: z["shopID"]
              } if params[:shop_id] == z["shopID"]
            end.compact
          end
         items << zz
         break
       end
       items << payload.map do |x|
         x.dig("ItemShops","ItemShop").map do |z|
           {
             item: z["itemID"],
             name: x["description"],
             price: x["Prices"]["ItemPrice"].first["amount"].to_f,
             cost: x["defaultCost"].to_f,
             sku: x["manufacturerSku"],
             qoh: z["qoh"],
             shop: z["shopID"]
           } if params[:shop_id] == z["shopID"]
         end.compact
       end.compact
       counter += 100
     end
     items.flatten.as_json
  end

  def get_counts
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/InventoryCount.json", headers: headers).parsed_response
  end

  def get_sales_issue
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Sale.json?load_relations=%5B%22SaleLines.Item%22%5D&timeStamp=><,#{Time.zone.now - 7.days},#{Time.zone.now}&offset=0", headers: headers).parsed_response
  end

  def update_purchase_order_status(params)
    payload = {
      "CustomFieldValues": {
      "CustomFieldValue": {
         "customFieldID": "1",
         "value": params[:gecko_id]
        }
      }
    }
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/Order/#{params[:id]}.json")
  end

  def update_item_oro_sku(params)
    payload = {
      "CustomFieldValues": {
      "CustomFieldValue": {
         "customFieldID": "1",
         "value": params[:sku]
        }
      }
    }
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/Item/#{params[:id]}.json",  body: JSON.dump(payload), headers: headers).parsed_response
  end

  def update_item_oro_supplier(params)
    payload = {
      "CustomFieldValues": {
      "CustomFieldValue": {
         "customFieldID": "2",
         "value": params[:supplier]
        }
      }
    }
    res = self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/Item/#{params[:id]}.json",  body: JSON.dump(payload), headers: headers)
    res.parsed_response
  end

  def get_account
    self.class.get("https://api.lightspeedapp.com/API/Account", headers: headers).parsed_response
  end

  def get_sale(params)
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Sale/#{params[:id]}.json?load_relations=%5B%22SaleLines.Item%22%5D", headers: headers).parsed_response
  end

  def get_sales_basic(params)
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Sale.json?load_relations=%5B%22SaleLines.Item%22%5D", headers: headers).parsed_response
  end

  def get_recent_purchase_orders
    current_date = Date.today.end_of_day
    former_date = Date.today - 7.days + 9.hours
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Order.json?load_relations=%5B%22CustomFieldValues%22%5D&timeStamp=><,#{former_date},#{current_date}", headers: headers).parsed_response
  end

  def get_sales
    offset = 0
    full_sales = []
    current_date = Date.today + 5.hours
    former_date = Date.today - 7.days + 9.hours
    counter = 0
    while offset < 1000000
      self.refresh_token
      sleep 2
      sales = self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Sale.json?load_relations=%5B%22SaleLines.Item%22%5D&timeStamp=><,#{former_date},#{current_date}&offset=#{offset}", headers: headers).parsed_response
      if sales["httpCode"]
        puts "________PROBLEM______________"
        puts offset
        puts sales
        puts "________PROBLEM______________"
      end
      break if sales["Sale"].nil?
      sales["Sale"].each do |s|
        full_sales << s
      end
      offset += 100
      sleep 2
    end
    full_sales
  end

  def delete_product(params)
    self.class.delete("https://api.lightspeedapp.com/API/Account/#{account}/Item/#{params[:id]}.json", headers: headers).parsed_response
  end

  def inventory_count_item
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/InventoryCountItem.json", headers: headers).parsed_response
  end

  def create_count(params)
    payload = {
      "shopID": params[:shop_id],
      "name": params[:name]
    }
    self.class.post("https://api.lightspeedapp.com/API/Account/#{account}/InventoryCount.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def update_po_cv(params)
    self.refresh_token
    sleep 1
    payload = {
      "CustomFieldValues": {
        "CustomFieldValue": {
          "customFieldID": "2",
          "value": "true"
        }
      }
    }
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/Order/#{params[:id]}.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def headers
    {
      'Authorization': "Bearer #{light_key}",
      "Content-Type": "application/json"
    }
  end

  def create_order_line_item(params)
    payload = {
      "quantity": params[:quantity].to_i,
      "price": params[:cost].to_f,
      "numReceived": "0",
      "itemID": params[:product_id].to_i,
      "orderID": params[:order_id].to_i
    }
    self.class.post("https://api.lightspeedapp.com/API/Account/#{account}/OrderLine.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def update_order_line_item(params)
    payload = {
      "quantity": params[:quantity].to_i,
      "price": params[:cost].to_f,
      "numReceived": "0",
      "itemID": params[:product_id].to_i,
      "orderID": params[:order_id].to_i
    }
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/OrderLine/#{params[:id]}.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def update_order_line_item_price(params)
    payload = {
      "price": params[:cost].to_f,
      "itemID": params[:product_id].to_i,
      "orderID": params[:order_id].to_i
    }
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/OrderLine/#{params[:id]}.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  ## @TODO consider cleanup the method as acount may be only one
  def get_accounts
    self.class.get("https://api.lightspeedapp.com/API/Account.json", headers: headers).parsed_response
  end

  def get_products
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Item.json?load_relations=%5B%22CustomFieldValues%22%2c%22ItemShops%22%5D", headers: headers).parsed_response
  end

  def get_paged_products(params)
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Item.json?limit=100&offset=#{params[:offset]}&load_relations=%5B%22CustomFieldValues%22%5D", headers: headers).parsed_response
  end

  def get_products_custom
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Item.json?load_relations=%5B%22CustomFieldValues%22%5D", headers: headers).parsed_response
  end

  def get_product(params)
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Item/#{params[:id]}.json?load_relations=%5B%22ItemShops%22%5D", headers: headers).parsed_response
  end

  def get_custom_product(params)
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Item/#{params[:id]}.json?load_relations=%5B%22CustomFieldValues%22%2c%22ItemShops%22%5D", headers: headers).parsed_response
  end

  def create_product(params)
    payload = {
      "description": params[:name],
      "defaultCost": params[:wholesale_cost],
      "manufacturerSku": params[:upc],
      "customSku": params[:sku],
      "Prices": {
        "ItemPrice": [
            {
              "amount": params[:cost],
              "useTypeID": "1",
              "useType": "Default"
            }
          ]
        },
        "CustomFieldValues": {
        "CustomFieldValue": {
           "customFieldID": "1",
           "value": params[:gecko_id]
          }
        }
      }
    self.class.post("https://api.lightspeedapp.com/API/Account/#{account}/Item.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def create_product_simple(params)
    payload = {
      "description": params[:name],
      "defaultCost": params[:wholesale_cost],
      "manufacturerSku": params[:upc],
      "customSku": params[:sku],
      "Prices": {
        "ItemPrice": [
            {
              "amount": params[:cost],
              "useTypeID": "1",
              "useType": "Default"
            }
          ]
        }
      }
    self.class.post("https://api.lightspeedapp.com/API/Account/#{account}/Item.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def update_product(params)
    payload = {
      "Prices": {
        "ItemPrice": [
          {
            "amount": params[:price],
            "useType": "Default"
          }
        ]
      }
    }
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/Item/#{params[:id]}.json", body: JSON.dump(payload), headers: headers).parsed_response
  end

  def update_inventory(id, payload)
    inventory = {
      "ItemShops": {
        "ItemShop": payload
      }
    }
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/Item/#{id}.json", body: JSON.dump(inventory), headers: headers).parsed_response
  end

  def inventory_count
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/InventoryCount.json", headers: headers).parsed_response
  end

  def update_item(params)
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/Item/#{params["itemID"]}.json", headers: headers, body: JSON.dump(params)).parsed_response
  end

  def update_item_sku(params)
    payload = {
      "manufacturerSku": params[:sku]
    }
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/Item/#{params[:id]}.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def get_shops
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Shop.json?load_relations=all", headers: headers).parsed_response
  end

  def get_shop(params)
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Shop/#{params[:id]}.json?load_relations=all", headers: headers).parsed_response
  end

  # def get_item_shops
  #   self.class.get("https://api.lightspeedapp.com/API/Account/#{@account}/ItemShop.json", headers: headers).parsed_response
  # end

  def purchase_orders(params = nil)
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Order.json?load_relations=%5B%22CustomFieldValues%22%2c%22OrderLines%22%2c%22OrderLines%22%5D", headers: headers).parsed_response
  end

  def purchase_order(params)
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Order/#{params[:id]}.json?load_relations=all", headers: headers).parsed_response
  end

  #
  # Get purchased orders with CustomField needed value from Lightspeed API 
  #
  # @param cf_name  [String] CustomField name
  # @param cf_value [String] CustomField value
  #
  # @return [Array] purchased orders
  def purchase_orders_with_custom_field(cf_name, cf_value)
    purchase_orders["Order"].select do |order|
      order["CustomFieldValues"] &&
        order["CustomFieldValues"]["CustomFieldValue"] &&
        order["CustomFieldValues"]["CustomFieldValue"].select{ |cf| cf["name"] == cf_name && cf["value"] == cf_value }.present?
    end
  end

  #
  # Get purchased orders with chedked CustomField "ready_for_oro" from Lightspeed API 
  #
  # @return [Array] purchased orders
  def purchase_orders_ready_for_oro
    @orders_ready_for_oro ||= purchase_orders_with_custom_field('ready_for_oro', 'true')
  end

  #
  # Get purchased orders with chedked CustomField "oro_completed" from Lightspeed API 
  #
  # @return [Array] purchased orders
  def purchase_orders_oro_completed
    @orders_oro_completed ||= purchase_orders_with_custom_field('oro_completed', 'true')
  end

  def order_line(params)
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/OrderLine/#{params[:id]}.json", headers: headers).parsed_response
  end

  def delete_order_line(params)
    self.class.delete("https://api.lightspeedapp.com/API/Account/#{account}/OrderLine/#{params[:id]}.json", headers: headers).parsed_response
  end

  def update_purchase_order_line(params)
    payload = {

    }
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/OrderLine/#{params[:id]}.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def vendors
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Vendor.json", headers: headers).parsed_response
  end

  def create_purchase_order(params = nil)
    payload = {
      "orderedDate": Time.zone.now,
      "stockInstruction": "Automatic Replenishment order for week of #{Time.zone.now}",
      "shopID": params[:shop_id]
    }
    self.class.post("https://api.lightspeedapp.com/API/Account/#{account}/Order.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def update_purchase_order(params)
    payload = {
      "OrderLines": {
        "OrderLine": [
          {
            "quantity"=>"5",
            "price"=>"5.99",
            "orderID"=>params[:id],
            "itemID"=>"4821"
          },
          {
            "quantity"=>"5",
            "price"=>"20.99",
            "orderID"=> params[:id],
            "itemID"=>"4636"
          }
        ]
      }
    }
    self.class.put("https://api.lightspeedapp.com/API/Account/#{account}/Order/#{params[:id]}.json", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def authorize_light(params)
    payload = {
      'code': params[:code],
      'client_secret': client_secret,
      'client_id': client_id,
      'grant_type': 'authorization_code'
    }
    res = self.class.post('https://cloud.lightspeedapp.com/oauth/access_token.php', body: JSON.dump(payload), headers: {"Content-Type": "application/json"}).parsed_response
    res
  end

  def inventory_count
    self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/InventoryCount.json", headers: headers).parsed_response
  end

  def refresh_token
    payload = {
      'refresh_token': refresh,
      'client_secret': client_secret,
      'client_id': client_id,
      'grant_type': 'refresh_token',
    }
    res = self.class.post('https://cloud.lightspeedapp.com/oauth/access_token.php', body: payload).parsed_response
    if res["httpCode"]
      sleep 5
      res = self.class.post('https://cloud.lightspeedapp.com/oauth/access_token.php', body: payload).parsed_response
    end
    @light_key = res["access_token"]
    self.update!(light_key: @light_key)
    res
  end

  def full_inventory
    full_inventory = []
    offset = 0
    sleep 3
    while offset < 10000
      self.refresh_token
      sleep 2
      items = self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Item.json?offset=#{offset}&archived=only", headers: headers).parsed_response
      if items["httpCode"]
        sleep 3
        items = self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Item.json?offset=#{offset}&archived=only", headers: headers).parsed_response
      end
      break if !items["Item"] || items["Item"].empty?
      full_inventory << items["Item"]
      offset += 100
    end

    full_inventory
  end

  def empty_inventory
    offset = 0
    full_items = {}
    sleep 3
    while offset < 10000
      self.refresh_token
      sleep 1
      items = self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Item.json?archived=false&offset=#{offset}&load_relations=%5B%22CustomFieldValues%22%2c%22ItemShops%22%5D", headers: headers).parsed_response
      if items["httpCode"]
        sleep 3
        items = self.class.get("https://api.lightspeedapp.com/API/Account/#{account}/Item.json?archived=false&offset=#{offset}&load_relations=%5B%22CustomFieldValues%22%2c%22ItemShops%22%5D", headers: headers).parsed_response
      end
      break if items["Item"].nil?
      items["Item"].each do |z|
        next if z["archived"] == "true"
        z["ItemShops"]["ItemShop"].each do |x|
          if full_items[x["shopID"]]
            next if x["qoh"].to_i > 0
            full_items[x["shopID"]] << { "itemID": x["itemID"], "quantity": "1", "defaultCost": z["defaultCost"] }.as_json
          else
            next if x["qoh"].to_i > 0
            full_items[x["shopID"]] = []
            full_items[x["shopID"]] << { "itemID": x["itemID"], "quantity": "1", "defaultCost": z["defaultCost"] }.as_json
          end

        end
      end
      offset += 100
      sleep 2
    end

    full_items
  end

  def sale_count_by_shop
    self.refresh_token
    payload = self.get_sales
    shops = {"1": [], "2": [], "3": [], "4": [], "5": [], "6": [], "7": [], "8": [], "9": []}.as_json
    returning_values = shops.keys.map do |x|
      total = 0
      counter = payload
                  .reject { |y| y["SaleLines"].nil? || y["completed"] == "false" }
                  .select {|z| z["shopID"] == x }
      total_count = counter.count
      counter.each {|c| total += c["calcAvgCost"].to_f }
      {shop: x, count: total_count, total_cost: total }
    end
    returning_values
  end
end
