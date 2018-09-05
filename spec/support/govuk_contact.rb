RSpec.shared_examples_for "a GOV.UK contact" do
  context "on GET" do
    it "returns http success" do
      get :new
      expect(response).to be_successful
    end

    it "should set cache control headers for 10 mins" do
      get :new
      expect(response.headers["Cache-Control"]).to eq("max-age=600, public")
      expect(response).to be_successful
    end

    it "should return 406 when text/html isn't acceptable" do
      request.env['HTTP_ACCEPT'] = 'nothing'
      get :new

      expect(response.code).to eq("406")
    end
  end

  context "on POST" do
    it "should return 406 when text/html isn't acceptable" do
      stub_request(:any, /.*/)

      request.env['HTTP_ACCEPT'] = 'nothing'
      post :create, params: valid_params

      expect(response.code).to eq("406")
    end
  end
end
