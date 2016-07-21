require "spec_helper"

module Challah
  describe UserAttributeable do
    it "doesn't raise an error if the table doesn't exist yet" do
      expect {
        class OtherUser < ActiveRecord::Base
          include Challah::Userable
          @table_name = "other_users"
        end
      }.not_to raise_error
    end
  end
end
