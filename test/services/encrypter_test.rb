require 'test_helper'

class TestEncrypter < ActiveSupport::TestCase
  include Challah

  context "The encrypter class" do
    should "encrypt a string" do
      assert_not_nil Encrypter.encrypt("testing 123")
    end

    should "use bcrypt to encrypt a string" do
      BCrypt::Password.expects(:create).with('testing 123', :cost => 10)

      Encrypter.encrypt("testing 123")

      BCrypt::Password.unstub(:create)
    end

    should "compare two encrypted strings quickly" do
      pass = Encrypter.encrypt("test A")

      assert_equal true, Encrypter.compare(pass, "test A")
      assert_equal false, Encrypter.compare("test A", "test A")
    end
  end

  context "An encrypter instance" do
    setup do
      @enc = Encrypter.new
    end

    should "encrypt a string" do
      pass = @enc.encrypt('testing 123')
      assert_not_nil pass
    end

    should "encrypt a string at a provided cost" do
      @enc.cost = 5

      pass = @enc.encrypt('testing 456')

      bpass = BCrypt::Password.new(pass)

      assert_equal 5, bpass.cost
    end

    should "compare a string" do
      pass = @enc.encrypt("test A")

      assert_equal true, @enc.compare(pass, "test A")
      assert_equal false, @enc.compare("test A", "test A")
    end

    should "md5 hash a batch of strings" do
      expected = Digest::MD5.hexdigest("str1|str2|str3")
      assert_equal expected, @enc.md5('str1', 'str2', 'str3')
    end

    should "md5 hash a batch of strings with a different join" do
      @enc.joiner = ' - '
      expected = Digest::MD5.hexdigest("str1 - str2 - str3")
      assert_equal expected, @enc.md5('str1', 'str2', 'str3')
    end

    should "hash some strings a given number of times" do
      Digest::SHA512.expects(:hexdigest).times(10)

      @enc.hash('hash me')

      Digest::SHA512.unstub(:hexdigest)
    end
  end
end
