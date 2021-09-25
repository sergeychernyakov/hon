# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

OroApi.create(
  client_id: "",
  client_secret: ""
)

LightApi.create(
  client_id: '',
  client_secret: '',
  refresh: '',
  account: '',
  light_key: ''
)
AdminUser.create!(email: 'sergiy@sqsoft.com', password: 'pass.123', password_confirmation: 'pass.123', first_name: "Admin") if Rails.env.development?