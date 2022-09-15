# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :client
  attribute :user
  attribute :book
  # account is not used
  attribute :account
end