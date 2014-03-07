require 'spec_helper'

describe Challah do

  describe "::VERSION" do
    subject { Challah::VERSION }
    it { should be_kind_of(String) }
  end

  describe ".options" do
    it "has a hash of options" do
      expect(Challah.options).to be_kind_of(Hash)
    end

    it "has default options" do
      expect(Challah.options).to include(:access_denied_view)
      expect(Challah.options).to include(:api_key_enabled)
      expect(Challah.options).to include(:cookie_prefix)
      expect(Challah.options).to include(:email_validator)
      expect(Challah.options).to include(:password_validator)
      expect(Challah.options).to include(:skip_routes)
      expect(Challah.options).to include(:skip_user_validations)
      expect(Challah.options).to include(:storage_class)
      expect(Challah.options).to include(:user)
    end
  end

  describe ".user" do
    it "returns the default user model" do
      expect(Challah.user).to be_kind_of(Class)
      expect(Challah.user).to eq(User)
    end
  end

end
