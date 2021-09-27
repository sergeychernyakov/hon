desc "This task is called by the Heroku scheduler add-on"

task :transfer_purchased_orders_to_orodoro => :environment do
  Orodoro::OrdersSyncer.sync_all
end
