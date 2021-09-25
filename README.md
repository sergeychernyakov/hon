# Lightspeed POS <> Orodoro 

## Components 
- Ruby on Rails API 6.1 
- Postgres DB 
- Heroku Scheduler 

## Running Locally 

### Pre Reqs: 
Rails 6.1, Bundler 2+, Postgres, ruby 2.6.6

### Steps
1. git clone repository 
2. bundle install 
3. rails db:create 
4. rails db:migrate 
5. rails s (not needed or recommended, unless for Postman debugging)

### SET VARS
ORO_CLIENT: 
ORO_SECRET: 

###
Running tasks 
 1. lib/tasks/seed.rake (compiled listing of the ones that helped me build the application) 


## Purpose 
For V1 of this application we are polling purchase orders in Lightspeed POS and then pushing the purchase orders into Orodoro. I have written out quite a bit for the Lightspeed POS API, so that model is chunky from carrying it over to other projects where inevitably a V2 will come into the picture. 

The rest is self explanatory, except for the starting point, which is Heroku scheduler. Have a look at scheduler.rake, and you will find the polling mechanism, which is the starting line for the processing of the orders. We make a subsequent read with expanding to extra params, and then sanitize the line items into an array to post to Orodoro. Orodoro needs all parameters in ```OroApi.sanitize_order_lines(lightspeed_order_lines)```.

This is the extent of the needed functionality in V1. 

## Heroku 
1. Get added to team account 
2. https://devcenter.heroku.com/articles/heroku-cli#download-and-install

```heroku logs --tail```
```heroku logs -n 1000```
```heroku run rails c``` 
```heroku run rails db:migrate```
```git push heroku master```

