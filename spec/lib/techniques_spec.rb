require 'spec_helper'

module Challah
  describe Techniques do

    class SampleTechniqueClass

      def initialize(session)
      end

      def authenticate
        false
      end

      def persist?
        false
      end

    end

    describe ".register_technique" do

      it "adds a new technique class to the registered list" do
        expect(Challah.techniques).to_not include(:sample)
        Challah.register_technique(:sample, SampleTechniqueClass)
        expect(Challah.techniques).to include(:sample)
        Challah.remove_technique(:sample)
      end
    end

    describe ".remove_technique" do
      it "removes a new technique class from the registered list" do
        expect(Challah.techniques).to_not include(:sample)
        Challah.register_technique(:sample, SampleTechniqueClass)
        expect(Challah.techniques).to include(:sample)
        Challah.remove_technique(:sample)
        expect(Challah.techniques).to_not include(:sample)
      end
    end

    describe ".techniques" do
      it "is a hash of registered techniques" do
        expect(Challah.techniques).to be_kind_of(Hash)
      end

      it "contains the basic techniques packaged with the gem" do
        expect(Challah.techniques).to include(:password)
        expect(Challah.techniques).to include(:api_key)
      end
    end

  end
end
