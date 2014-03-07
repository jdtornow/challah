require 'spec_helper'

module Challah
  # TODO make these specs not look like unit tests
  describe Encrypter do

    let(:instance) { Encrypter.new }

    describe ".encrypt" do
      it "encrypts a string" do
        expect(Encrypter.encrypt("testing 123")).to_not be_nil
      end

      it "uses bcrypt to encrypt a string" do
        BCrypt::Password.expects(:create).with('testing 123', :cost => 10)
        Encrypter.encrypt("testing 123")
        BCrypt::Password.unstub(:create)
      end
    end

    describe ".compare" do
      it "should compare two encrypted strings quickly" do
        pass = Encrypter.encrypt("test A")

        assert_equal true, Encrypter.compare(pass, "test A")
        assert_equal false, Encrypter.compare("test A", "test A")
      end
    end

    describe "#compare" do
      it "should compare a string" do
        pass = instance.encrypt("test A")

        assert_equal true, instance.compare(pass, "test A")
        assert_equal false, instance.compare("test A", "test A")
      end
    end

    describe "#encrypt" do
      it "encrypts a string" do
        pass = instance.encrypt('testing 123')
        expect(pass).to_not be_nil
      end

      it "encrypts a string at a provided cost" do
        instance.cost = 5
        pass = instance.encrypt('testing 456')
        bpass = BCrypt::Password.new(pass)
        expect(bpass.cost).to eq(5)
      end
    end

    describe "#hash" do
      it "hashes some strings a given number of times" do
        Digest::SHA512.expects(:hexdigest).times(10)
        instance.hash('hash me')
        Digest::SHA512.unstub(:hexdigest)
      end
    end

    describe "#md5" do
      it "md5 hashes a batch of strings" do
        expected = Digest::MD5.hexdigest("str1|str2|str3")
        expect(instance.md5('str1', 'str2', 'str3')).to eq(expected)
      end

      it "md5 hashes a batch of strings with a different join" do
        instance.joiner = ' - '
        expected = Digest::MD5.hexdigest("str1 - str2 - str3")
        expect(instance.md5('str1', 'str2', 'str3')).to eq(expected)
      end
    end

  end
end
