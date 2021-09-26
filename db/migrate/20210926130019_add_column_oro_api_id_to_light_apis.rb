class AddColumnOroApiIdToLightApis < ActiveRecord::Migration[6.0]
  def change
    add_column :light_apis, :oro_api_id, :integer
  end
end
