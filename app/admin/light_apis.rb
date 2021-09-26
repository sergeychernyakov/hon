ActiveAdmin.register LightApi do

  permit_params :client_id, :client_secret, :refresh, :account, :light_key, :oro_api_id

  #  ____ ___  ___  _
  # | |_ / / \| |_)| |\/|
  # |_|  \_\_/|_| \|_|  |

  form title: ->(light_api) { light_api.persisted? ? "Editing Light Api" : "New Light Api" } do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :oro_api_id, as: :select, collection: options_from_collection_for_select(OroApi.order(:client_id), 'id', 'client_id')
      f.input :client_id
      f.input :client_secret
      f.input :refresh
      f.input :account
      f.input :light_key
      actions
    end
  end
  
end
