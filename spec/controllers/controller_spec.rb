require "spec_helper"

module Challah
  describe MockController do

    let(:user) { create(:user) }
    let(:controller) { MockController.new }

    describe "#current_user?" do
      context "with a valid session" do
        before do
          session = Session.create(user)
          session.save
        end

        it "is signed in" do
          expect(controller.send(:current_user?)).to eq(true)
        end
      end

      context "without a session" do
        it "is signed out by default" do
          expect(controller.send(:current_user?)).to eq(false)
        end
      end
    end

    describe "#current_user" do
      context "with a valid session" do
        before do
          session = Session.create(user)
          session.save
        end

        it "has method" do
          expect(controller.send(:current_user)).to eq(user)
        end
      end
    end

    describe "#signed_in?" do
      context "with a valid session" do
        before do
          session = Session.create(user)
          session.save
        end

        it "has method" do
          expect(controller.send(:signed_in?)).to eq(true)
        end
      end

      context "without a session" do
        before do
          controller.request.url = 'http://example.com/protected-page'
          allow(controller).to receive(:signed_in?).and_return(false)
        end

        it "redirects to the login page" do
          expect(controller).to receive(:redirect_to).once
          controller.send(:signin_required)

          expect(controller.session).to include(:return_to)
          expect(controller.session[:return_to]).to eq("http://example.com/protected-page")
        end
      end
    end
  end
end
