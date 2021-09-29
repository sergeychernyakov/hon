require 'rails_helper'

describe LightApi, type: :model do

  let(:light_api) { LightApi.new(client_secret: "API Secret", client_id: "API Client Id", account: "333333", light_key: "Test Light key") }
  let(:account_name) { 'Test Account' }

  describe "attribtes" do
    subject { light_api.attributes }

    it { should include 'client_secret' }
    it { should include 'client_id' }
    it { should include 'light_key' }
    it { should include 'account' }
    it { should include 'status' }
  end

  describe "client_secret" do
    subject { light_api.client_secret }

    it { should =~ /API Secret/ }
  end

  describe "client_id" do
    subject { light_api.client_id }

    it { should =~ /API Client Id/ }
  end

  context "with stubbed accounts" do

    before do
      stub_request(:get, "https://api.lightspeedapp.com/API/Account").
        with(headers: light_api.headers).
        to_return(body: "<Accounts count=1><Account><accountID>#{light_api.account}</accountID><name>#{account_name}</name>")
    end

    describe "#get_account" do
      subject { light_api.get_account }
      it { expect(light_api.get_account).to include("#{light_api.account}") }
      it { expect(light_api.get_account).to include("#{account_name}") }
    end

  end


  context "with stubbed Shops" do

    let(:shop_name) { 'Test Shop' }
    let(:shop_id) { '111111' }

    before do
      stub_request(:get, "https://api.lightspeedapp.com/API/Account/#{light_api.account}/Shop.json?load_relations=all").
        with(headers: light_api.headers).
        to_return(body: '{"@attributes"=>{"count"=>"1", "offset"=>"0", "limit"=>"100"}, "Shop"=>{"shopID"=>"#{shop_id}", "name"=>"#{shop_name}", "serviceRate"=>"0", "timeZone"=>"EST", "taxLabor"=>"false", "labelTitle"=>"Shop Name", "labelMsrp"=>"false", "archived"=>"false", "timeStamp"=>"2021-09-25T06:06:53+00:00", "companyRegistrationNumber"=>"", "vatNumber"=>"", "zebraBrowserPrint"=>"true"}}')
    end

    describe "#get_shops" do
      subject { light_api.get_shops }
      it { expect(light_api.get_shops).to include("shopID") }
      it { expect(light_api.get_shops).to include("name") }
    end

  end

end