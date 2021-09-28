ActiveAdmin.register OroApi do

  permit_params :client_id, :client_secret, :oro_key, :refresh_key, :merchant_id, :name

  #  ____ ___  ___  _
  # | |_ / / \| |_)| |\/|
  # |_|  \_\_/|_| \|_|  |

  form title: ->(oro_api) { oro_api.persisted? ? "Editing Oro Api" : "New Oro Api" } do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :name
      f.input :client_id
      f.input :client_secret
      f.input :oro_key
      f.input :refresh_key
      f.input :merchant_id
      actions
    end
  end
  
end
