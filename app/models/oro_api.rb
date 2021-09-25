class OroApi < ApplicationRecord
  include HTTParty


  def self.sanitize_order_lines(params)
    sanitized_lines = params[:lines].map do |ol|
      {
      "sku": ol["sku"],
      "quantity": ol["quantity"].to_i,
      "unit_price": ol["cost"].to_f,
      "discount_amount": 0
      }
    end
    sanitized_lines
  end

  def item_by_sku(params)
    self.class.get("https://api.ordoro.com/product/#{params[:sku]}/", headers: headers).parsed_response
  end

  def headers
    {
      "Authorization": "Basic #{Base64.encode64("#{ENV["ORO_CLIENT"]}:#{ENV["ORO_SECRET"]}").gsub("\n", "")}",
      "Content-Type": "application/json"
    }
    #{ENV["ORO_CLIENT"]}:#{ENV["ORO_SECRET"]}
  end

  def get_account_balance
    self.class.get("https://api.ordoro.com/v3/account/balance", headers: headers).parsed_response
  end

  def purchase_orders
    self.class.get("https://api.ordoro.com/purchase_order/", headers: headers).parsed_response
  end

  def warehouses
    self.class.get("https://api.ordoro.com/warehouse/", headers: headers).parsed_response
  end

  def suppliers
    self.class.get("https://api.ordoro.com/supplier/", headers: headers).parsed_response
  end

  def create_purchase_order(params)
    payload = {
      "supplier_id": 0,
      "warehouse_id": 0,
      "po_id": "string",
      "shipping_method": "Lightspeed Store",
      "payment_method": "Lightspeed Store",
      "instructions": "This is a Lightspeed Store Test. Please do not process",
      "shipping_amount": 0,
      "tax_amount": 0,
      "discount_amount": 0,
      "items": params[:lines]
    }
    self.class.post("https://api.ordoro.com/purchase_order/", headers: headers, body: JSON.dump(payload)).parsed_response
  end

  def self.map_lines(lines)
    lines.map do |line|
      {
        "quantity": line["quantity"],
        "product": {
          "sku": line["sku"],
          "name": line["name"],
          "price": ('%.2f' % line["price"]).to_f,
          "taxable": "false",
          "cost": ('%.2f' % line["cost"]).to_f
        }
      }
    end
  end

  def create_sales_order(params)
    payload = OroApi.create_sales_order_payload(lines: params[:lines])
    res = self.class.post("https://api.ordoro.com/v3/order", headers: headers, body: JSON.dump(payload)).parsed_response
    binding.pry
    res
  end

  def self.create_sales_order_payload(params)
    mapped_lines = params[:lines].map do |z|
        {
          "product_name": z["name"],
          "total_price": z["cost"] * z["quantity"].to_f,
          "product": {
              "cost": z["cost"],
              "name": z["name"],
              "price": z["price"],
              "sku": z["sku"],
              "taxable": "false",
              "weight": 1
          },
          "quantity": z["quantity"]
        }
    end
    counter = 0.0
    mapped_lines.each {|x| counter += x[:total_price] }
    payload = {
        "billing_address": {
            "city": "Athens",
            "country": "USA",
            "email": "info@frannysfarmacy.com",
            "name": "Test User",
            "phone": "7062249505",
            "state": "ga",
            "street1": "2361 West Broad Street",
            "zip": "30606"
        },
        "lines": mapped_lines,
        "product_amount": counter,
        "tax_amount": counter * 0.05,
        "grand_total": counter + (counter * 0.05),
        "order_date": Time.zone.now.to_s,
        "order_id": "myorder-id-test10",
        "shipping_address": {
            "city": "Athens",
            "country": "USA",
            "email": "info@frannysfarmacy.com",
            "name": "Test User",
            "phone": "7062249505",
            "state": "ga",
            "street1": "2361 West Broad Street",
            "zip": "30606"
        },
      "tags": [{ "color": "#C0C0C0", "text": "Test Order"}]
    }

    payload.as_json
  end
end
