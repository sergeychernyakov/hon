require 'rails_helper'

describe LightApi, type: :model do

  let(:light_api) { LightApi.new(client_secret: "Test Secret", client_id: "Test Client Id", account: "Test account") }

  before do
  	light_api.refresh_token

  	stub_request(:get, "https://api.lightspeedapp.com/API/Account/#{light_api.account}/InventoryCountReconcile.json").
     with(
       body: "refresh_token=&client_secret=Test%20Secret&client_id=Test%20Client%20Id&grant_type=refresh_token",
       headers: {
   	  'Accept'=>'*/*',
   	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
   	  'User-Agent'=>'Ruby'
       }).
     to_return(status: 200, body: "{'attributes'=>{'count'=>'0'}}", headers: {})




    # stub_request(:get, "https://api.lightspeedapp.com/API/Account/#{light_api.account}/InventoryCountReconcile.json").
    #   to_return(:status => 200, :body => '{"attributes"=>{"count"=>"0"}}')
  end

  describe "field_names" do
    subject { shipstation.field_names }

    it { should include 'client_secret' }
    it { should include 'client_id' }
    it { should include 'account' }
  end

  describe "attribtes" do
    subject { light_api.attributes }

    it { should == {"count"=>"0"} }
  end

  # context "with stubbed products" do

  #   before do
  #     stub_request(:get, "https://ssapi.shipstation.com/products?page=1&pageSize=500").
  #       to_return(:status => 200, :body => '{"products":[{"productId":149954969,"sku":"ABC123","name":"Test item #1","price":99.99},{"productId":149954970,"sku":"ABC345","name":"Test item #2","price":199.99}]}')
  #   end

  #   describe "#products" do
  #     subject { shipstation.products }
  #     it { should == [["ABC123", "Test item #1 99.99"], ["ABC345", "Test item #2 199.99"]] }
  #   end

  #   describe "#stores" do
  #     subject { shipstation.stores }

  #     before do
  #       stub_request(:get, "https://ssapi.shipstation.com/stores").
  #         to_return(status: 200, body: '[{"storeId":149954969,"storeName":"Test item #1"},{"storeId":149954970,"storeName":"Test item #2"}]')
  #     end

  #     it { should == [[149954969, "Test item #1"], [149954970, "Test item #2"]] }
  #   end

  #   describe "to" do
  #     subject { shipstation.to }
  #     it { should include 'products' }
  #     it { should include 'stores' }
  #   end

  #   describe "with" do
  #     subject { shipstation.with('products') }
  #     it { should eql shipstation.products }
  #   end

  # end

end