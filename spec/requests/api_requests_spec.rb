require "spec_helper"

RSpec.describe "JSON API Requests", type: :request do

  let(:user) { create(:user) }

  let(:headers) do
    json_headers.merge({
      "X-Auth-Token" => user.api_key
    })
  end

  let(:json_headers) do
    {
      "ACCEPT" => "application/json",
      "HTTP_ACCEPT" => "application/json",
    }
  end

  before do
    Challah.options[:token_enabled] = true
    Challah.options[:token_header] = "X-Auth-Token"
    user
  end

  def json_response
    return {} unless response.body
    @json_response ||= JSON.parse(response.body)
  end

  describe "GET /api/sample" do
    context "with no user" do
      before do
        get "/api/sample", {}, json_headers
      end

      it "returns unauthorized" do
        expect(response.status).to eq(401)
        expect(assigns(:current_user)).to be_nil
      end
    end

    context "with a regular user and header token" do
      before do
        get "/api/sample", {}, headers
      end

      it "has a successful response" do
        expect(response.status).to eq(200)
        expect(assigns(:current_user)).to eq(user)

        expect(json_response["message"]).to eq("Success!")
        expect(json_response["user"]["id"]).to eq(user.id)
      end
    end

    context "with a regular user and invalid auth token" do
      let(:headers) do
        json_headers.merge({
          "X-Auth-Token" => "bad-api token"
        })
      end

      before do
        get "/api/sample", {}, headers
      end

      it "returns unauthorized" do
        expect(response.status).to eq(401)
        expect(assigns(:current_user)).to be_nil
      end
    end

    context "with a regular user and token param" do
      before do
        get "/api/sample", { token: user.api_key }, json_headers
      end

      it "has a successful response" do
        expect(response.status).to eq(200)
        expect(assigns(:current_user)).to eq(user)

        expect(json_response["message"]).to eq("Success!")
        expect(json_response["user"]["id"]).to eq(user.id)
      end
    end

    context "with an invalid token param" do
      before do
        get "/api/sample", { token: "bad-api-key" }, json_headers
      end

      it "returns unauthorized" do
        expect(response.status).to eq(401)
        expect(assigns(:current_user)).to be_nil
      end
    end

    context "with a regular user and customized header token" do

      let(:headers) do
        json_headers.merge({
          "X-User-Api-Token" => user.api_key
        })
      end

      before do
        Challah.options[:token_header] = "X-User-Api-Token"

        get "/api/sample", {}, headers
      end

      it "has a successful response" do
        expect(response.status).to eq(200)
        expect(assigns(:current_user)).to eq(user)

        expect(json_response["message"]).to eq("Success!")
        expect(json_response["user"]["id"]).to eq(user.id)
      end
    end
  end
end
