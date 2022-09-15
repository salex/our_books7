class Stash < ApplicationRecord
  acts_as_tenant(:client)
  belongs_to :book

  serialize :json, JSON
end
