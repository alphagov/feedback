shared_examples_for "a GOV.UK contact" do
  context "on GET" do
    it "returns http success" do
      get :new
      response.should be_success
    end

    it "should set cache control headers for 10 mins" do
      get :new
      response.headers["Cache-Control"].should == "max-age=600, public"
      response.should be_success
    end

    it "should return 406 when text/html isn't acceptable" do
      request.env['HTTP_ACCEPT'] = 'nothing'
      get :new

      response.code.should eq("406")
    end

    it "should send a dummy artefact to slimmer with a Contact section" do
      controller.should_receive(:set_slimmer_dummy_artefact).with(section_name: "Contact", section_link: "/contact")
      get :new
    end
  end

  context "on POST" do
    it "should return 406 when text/html isn't acceptable" do
      stub_request(:any, /.*/)

      request.env['HTTP_ACCEPT'] = 'nothing'
      post :create, valid_params

      response.code.should eq("406")
    end
  end
end
