class Orodoro::Modificator::SetItemPayload
  def self.call(items, light_api)
    new(items, light_api).call
  end

  def initialize(items, light_api)
    @items = items
    @light_api = light_api
  end

  def call
    build_items
    build_item_quantity
    @payload
  end

  private

  attr_reader :items, :light_api

  def build_items
    new_items = []
    counter = 0
    while counter < 1000
      light_api.refresh_token
      sleep 3
      payload_data = payload(counter)
      break if payload_data.nil? || payload_data.empty?

      if payload_data.instance_of?(Hash)
        obj = [payload_data].map do |x|
          item_attributes(x)
        end
        new_items << obj
        break
      end

      new_items << payload_data.map do |x|
        item_attributes(x)
      end.compact
      counter += 100
    end
    @payload = new_items.flatten.as_json
  end

  def payload(counter)
    ids_to_params = '%5B%22' + item_ids.compact.join('%22%2c%22') + '%22%5D'

    response = LightApi.get("https://api.lightspeedapp.com/API/Account/#{light_api.account}/Item.json?offset=#{counter}&load_relations=%5B%22ItemShops%22%2c%22CustomFieldValues%22%5D&itemID=IN,#{ids_to_params}", headers: light_api.headers).parsed_response
    response.dig('Item')
  end

  def item_attributes(x)
    x.dig('ItemShops', 'ItemShop')
     .map do |z|
      {
        name: x['description'],
        item: z['itemID'],
        price: x['Prices']['ItemPrice'].first['amount'].to_f,
        cost: x['defaultCost'].to_f,
        sku: x['manufacturerSku'],
        qoh: z['qoh'],
        shop: z['shopID']
      }
    end.compact
  end

  def item_ids
    items.pluck('itemID')
  end

  def build_item_quantity
    @payload.each do |payload_item|
      payload_item['quantity'] = items.find { |item| item['itemID'] == payload_item['item'] }&.fetch('quantity').to_i
    end
  end
end
