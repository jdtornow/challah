require "spec_helper"

module Challah
  describe Authorization do
    describe "#user" do
      let(:user) { create(:user) }
      let(:authorization) { Authorization.set(user_id: user.id, provider: :test) }

      it "references an authorization record's user" do
        expect(authorization.user).to eq(user)
      end
    end

    describe ".del" do
      it "removes a record" do
        Authorization.set(user_id: 1, provider: :test, token: "test123")

        expect {
          Authorization.del(user_id: 1, provider: :test)
        }.to change { Authorization.count }.by(-1)
      end
    end

    describe ".get" do
      let(:user) { create(:user) }
      let(:authorization) { Authorization.set(user_id: user.id, provider: :test) }

      before { authorization }

      it "loads a user provider record" do
        expect(Authorization.get(user_id: user.id, provider: :test)).to eq(authorization)
      end
    end

    describe ".hashable_attributes" do
      it "has a list of attributes that are hashable" do
        expected_columns = %w( id uid token expires_at ).sort
        expect(Authorization.hashable_attributes.sort).to eq(expected_columns)
      end
    end

    describe ".set" do
      it "adds a record" do
        expect {
          Authorization.set(user_id: 1, provider: :test, token: "test123")
        }.to change { Authorization.count }.by(1)
      end

      it "removes existing provider records" do
        Authorization.set(user_id: 1, provider: :test, token: "480065006C006C006F00200077006F0072006C006400")

        expect {
          Authorization.set(user_id: 1, provider: :test, token: "test123")
        }.to_not change { Authorization.count }
      end
    end

    describe ".user_model" do
      it "references the user model" do
        expect(Authorization.user_model).to eq(User)
        expect(Authorization.users_table_name).to eq("users")
      end
    end

    describe ".users_table_name" do
      it "references the users table" do
        expect(Authorization.users_table_name).to eq("users")
      end
    end
  end
end
