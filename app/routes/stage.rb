class Portal < Sinatra::Application
  get "/stage" do
    PortalData.first.stage
  end
end
