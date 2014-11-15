require 'spec_helper'

module Challah
  describe Random do
    describe ".token" do
      context "with ActiveSupport" do
        it "provides a random string" do
          result = Random.token(10)

          expect(result).to_not be_nil
          expect(result.size).to eq(10)
        end
      end

      context "without ActiveSupport" do
        before do
          allow(Random).to receive(:secure_random?).and_return(false)
        end

        it "provides a random string" do
          expect(SecureRandom).to_not receive(:hex)

          result = Random.token(10)

          expect(result).to_not be_nil
          expect(result.size).to eq(10)
        end
      end
    end
  end
end
