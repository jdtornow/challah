require 'spec_helper'

module Challah
  describe AuthenticatedRoutingConstraint, type: :routing do
    let(:user)  { create(:user)  }
    let(:admin) { create(:admin) }

    context "without a signed in admin user" do
      it "should not allow non admin users" do
        expect(get("/admin/dashboard")).not_to be_routable
      end

      it "should not allow someone not logged in to access the profile page" do
        expect(get("/profile")).to_not be_routable
      end
    end

    context "with a signed in user that is not an admin" do
      before(:each) do
        signin_as(user)
      end

      it "should not allow non admin users to the admin dashboard" do
        expect(get("/admin/dashboard")).not_to be_routable
      end

      it "should allow a logged in user to access their profile" do
        expect(get("/profile")).to be_routable
      end
    end

    context "with a signed in admin user" do
      before do
        signin_as(admin)
      end

      it "should allow admin users" do
        expect(get("/admin/dashboard")).to be_routable
      end
    end
  end
end
