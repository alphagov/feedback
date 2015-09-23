module PathHelpers
  # Takes a URL path (with optional query string), and asserts that it matches the current URL.
  def i_should_be_on(path_with_query)
    expected = URI.parse(path_with_query)
    current = URI.parse(current_url)
    expect(current.path).to eq(expected.path)
    expect(Rack::Utils.parse_query(current.query)).to eq(Rack::Utils.parse_query(expected.query))
  end
end

RSpec.configuration.include PathHelpers, type: :request
