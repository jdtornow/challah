require "spec_helper"

module Challah
  describe RestrictionsController, type: :request do

    let(:user) { create(:user) }

    describe "GET :index" do
      context "with no user" do
        before do
          signout
          get "/challah"
        end

        it "has a successful response" do
          expect(response.status).to eq(200)
        end

        it "has a blank user" do
          expect(assigns(:current_user)).to be_nil
        end
      end

      context "with a regular user" do
        before do
          signin_as(user)
          get "/challah"
        end

        it "has a successful response" do
          expect(response.status).to eq(200)
        end

        it "has the user" do
          expect(assigns(:current_user)).to eq(user)
        end
      end

      context "with an api user" do
        before do
          Challah.options[:api_key_enabled] = true
          get "/challah", key: user.api_key
        end

        it "has a successful response" do
          expect(response.status).to eq(200)
        end

        it "has the user" do
          expect(assigns(:current_user)).to eq(user)
        end
      end

      context "with an api user but disabled api mode" do
        before do
          Challah.options[:api_key_enabled] = false
          get "/challah", key: user.api_key
        end

        it "has a successful response" do
          expect(response.status).to eq(200)
        end

        it "has a blank user" do
          expect(assigns(:current_user)).to be_nil
        end
      end
    end

    describe "GET :edit" do
      context "with no user" do
        before do
          signout
          get "/challah/edit"
        end

        it "has a successful response" do
          expect(response).to redirect_to("/sign-in")
        end
      end

      context "with a regular user" do
        before do
          signin_as(user)
          get "/challah/edit"
        end

        it "has a successful response" do
          expect(response.status).to eq(200)
        end

        it "has the user" do
          expect(assigns(:current_user)).to eq(user)
        end
      end
    end

    describe "GET :show" do
      context "with no user" do
        before do
          signout
          get "/challah/show"
        end

        it "has a successful response" do
          expect(response).to redirect_to("/sign-in")
        end
      end

      context "with a regular user" do
        before do
          signin_as(user)
          get "/challah/show"
        end

        it "has a successful response" do
          expect(response.status).to eq(200)
        end

        it "has the user" do
          expect(assigns(:current_user)).to eq(user)
        end
      end
    end
  end
end
