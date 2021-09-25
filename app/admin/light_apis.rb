ActiveAdmin.register LightApi do

  permit_params :client_id, :client_secret, :refresh, :account, :light_key
  
end
