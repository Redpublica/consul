class MapLocation < ApplicationRecord
  belongs_to :proposal, touch: true

  validates :longitude, :latitude, :zoom, presence: true, numericality: true

  def available?
    latitude.present? && longitude.present? && zoom.present?
  end

  def json_data
    {
      proposal_id: proposal_id,
      lat: latitude,
      long: longitude
    }
  end
end
