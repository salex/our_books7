# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


# client = Client.create({                                                                                    
#  "name"=>"VFW Post 8600",                                                                    
#  "acct"=>"8600",                                                                             
#  "address"=>"PO Box 8601",                                                                   
#  "city"=>"Gadsden",                                                                          
#  "state"=>"AL",                                                                              
#  "zip"=>"35902",                                                                             
#  "phone"=>"256.456.2440",                                                                    
#  "subdomain"=>"post8600",                                                                    
#  "domain"=>"stevealex.us"})

# user = User.create({                                                                                  
#  "client_id"=>1,                                                                           
#  "email"=>"salex@mac.com",                                                                 
#  "username"=>"salex",                                                                      
#  "full_name"=>"Steven V Alex",                                                             
#  "roles"=>["super"],                                                                       
#  "default_book"=>nil,                                                                      
#  "password_digest"=>"$2a$12$sg7uS1AGnkBgUFWhfGb6heAYrOPoclsww/NoJUWZ0QGnjF1ZJRQe6"})

# book = Book.create({                              
#  "client_id"=>1,                       
#  "name"=>"Start ",                     
#  "date_from"=>"2014-01-01",            
#  "date_to"=>"2014-12-31",            
#  "settings"=> {skip:true}})

# accts = JSON.parse(File.read(Rails.root + "xml/json/vfw.json"))

# accts.each do |a|
#   new_acct = Account.new(a)
#   new_acct.book_id = 1 
#   new_acct.client_id = 1
#   new_acct.code = new_acct.type if new_acct.parent_id == 1
#   new_acct.code = 'ROOT' if new_acct.parent_id == nil
#   new_acct.save
# end

# ActiveRecord::Base.connection.reset_pk_sequence!('accounts')

