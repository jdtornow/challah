require "spec_helper"

module Challah
  describe ::Authorization do
    describe ".hashable_attributes" do
      it "has a list of attributes that are hashable" do
        expected_columns = %w( id uid token expires_at ).sort
        expect(::Authorization.hashable_attributes.sort).to eq(expected_columns)
      end
    end

    describe ".user_model" do
      it "references the user model" do
        expect(::Authorization.user_model).to eq(::User)
        expect(::Authorization.users_table_name).to eq("users")
      end
    end

    describe ".users_table_name" do
      it "references the users table" do
        expect(::Authorization.users_table_name).to eq("users")
      end
    end
  end
end
