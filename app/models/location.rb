class Location < ApplicationRecord
  include ActiveModel::Serialization

  def serializable_hash(_options = nil)
    super(only: %w[zipcode lat lng])
  end
end
