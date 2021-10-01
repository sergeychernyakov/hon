require 'rails_helper'

describe OroApi, type: :model do

  let(:oro_api) { OroApi.new(client_secret: "Oro API Secret", client_id: "Oro API Client Id", oro_key: "Test Oro Key") }
  
  describe "attribtes" do
    subject { oro_api.attributes }

    it { should include 'client_secret' }
    it { should include 'client_id' }
    it { should include 'oro_key' }
  end

  describe "client_secret" do
    subject { oro_api.client_secret }

    it { should =~ /Oro API Secret/ }
  end

  describe "client_id" do
    subject { oro_api.client_id }

    it { should =~ /Oro API Client Id/ }
  end

end