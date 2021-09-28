ActiveAdmin.register LightApi do

  permit_params :account, :client_id, :client_secret, :refresh, :light_key, :oro_api_id, :status

  #  ____ ___  ___  _
  # | |_ / / \| |_)| |\/|
  # |_|  \_\_/|_| \|_|  |

  form title: ->(light_api) { light_api.persisted? ? "Editing Light Api" : "New Light Api" } do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :account
      f.input :oro_api_id, as: :select, collection: options_from_collection_for_select(OroApi.order(:client_id), 'id', 'label', f.object.oro_api_id)
      f.input :client_id
      f.input :client_secret
      f.input :refresh
      f.input :light_key
      f.input :status
      actions
    end
  end

  index do
    selectable_column
      column :account
      column "Oro API" do |light_api|
        link_to light_api.oro_api.name, admin_oro_api_path(light_api.oro_api) if light_api.oro_api.present?
      end
      column :client_id
      column :status
    actions
  end
end
