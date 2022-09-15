class Client < ApplicationRecord
  has_many :books, dependent: :destroy
  has_many :users, dependent: :destroy


  serialize :settings, JSON
  attribute :setting

end
