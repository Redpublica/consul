class Proposals::MapProposalsComponent < ApplicationComponent
  delegate :wysiwyg, :auto_link_already_sanitized_html, :render_map, to: :helpers
  attr_reader :proposals

  def initialize(proposals)
    @proposals = proposals.except(:limit, :offset)
  end

  def coordinates
    MapLocation.where(proposal_id: proposals).map(&:json_data)
  end
end
