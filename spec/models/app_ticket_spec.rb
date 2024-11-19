require "rails_helper"

RSpec.describe AppTicket, type: :model do
  it "returns true for valid_ticket? if giraffe blank" do
    ticket = AppTicket.new

    expect(ticket.valid_ticket?).to eq(true)
  end

  it "returns false for valid_ticket? if giraffe present" do
    ticket = AppTicket.new(giraffe: "i am a robot")

    expect(ticket.valid_ticket?).to eq(false)
  end
end
