require "spec_helper"
require "./spec/dummy/app/controllers/application_controller"

module Challah
  describe SessionsController do

    let(:user) { build(:user, username: 'sessions-user-test') }

    before do
      user.password! 'abc123'
      user.save
    end

    describe "GET /sign-in" do
      before { get :new }

      it "has a sign-in page" do
        expect(response.status).to eq(200)
      end
    end

    describe "POST /sign-in" do
      context "with valid credentials" do
        before do
          allow_any_instance_of(Session).to receive(:save).and_return(true)
          post :create, username: 'sessions-user-test', password: 'abc123'
        end

        it "signs the user in" do
          expect(response).to redirect_to("/")
        end
      end

      context "with invalid credentials" do
        before do
          allow_any_instance_of(Session).to receive(:save).and_return(false)
          post :create, username: 'sessions-user-test', password: ''
        end

        it "signs the user in" do
          expect(response).to redirect_to("/sign-in")
        end
      end
    end

    describe "GET /sign-out" do
      before do
        get :destroy
      end

      it "goes back to sign-in" do
        expect(response).to redirect_to("/sign-in")
      end
    end
  end
end
