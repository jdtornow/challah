require 'spec_helper'

module Challah
  # TODO make these specs not look like unit tests
  describe Audit do

    include ActiveModel::Lint::Tests

    # Use Widget as a fake model to test auditing.
    class Widget
      include ActiveModel::Conversion
      include ActiveModel::Validations
      extend ActiveModel::Naming
      extend ActiveModel::Callbacks

      define_model_callbacks :create, :update, :save

      include Challah::Audit

      attr_accessor :name, :created_by, :created_at, :updated_by, :updated_at, :changed_attributes

      def initialize(attributes = {})
        attributes.each do |name, value|
          send("#{name}=", value)
        end

        @attributes = {}
      end

      def changed_attributes
        @changed_attributes ||= ActiveSupport::HashWithIndifferentAccess.new
      end

      def persisted?
        false
      end

      def new_record?
        !@saved
      end

      def save
        # Saving doesn't do anything, just a stub
        run_callbacks :save do
          @saved = true
        end

        true
      end

      def column_for_attribute(attr_name)
        self.respond_to?("#{attr_name}=") ? attr_name : nil
      end

      def write_attribute(attr_name, value)
        self.send("#{attr_name}=", value)
      end

      # Stubs
      def attribute_changed?(attr_name)
        false
      end
    end

    # Runs the ActiveModel::Lint tests against a new Widget instance.
    before do
      @model = Widget.new
    end

    it "should be able to receive a current user" do
      user = create(:user)
      user_two = create(:user, :first_name => 'User', :last_name => 'Test 2')

      expect(@model.current_user_id).to eq(0)
      expect(@model.new_record?).to eq(true)

      # For a new record, setting current_user should update both attributes
      @model.current_user = user
      expect(@model.current_user_id).to eq(user.id)

      @model.save

      expect(@model.created_by).to eq(user.id)
      expect(@model.updated_by).to eq(user.id)

      expect(@model.new_record?).to eq(false)

      # For an existing record, setting current_user (or current_user_id) should update only updated_by
      @model.current_user_id = user_two.id
      expect(@model.current_user_id).to eq(user_two.id)

      @model.save

      expect(@model.created_by).to eq(user.id)
      expect(@model.updated_by).to eq(user_two.id)
    end

    it "should be able to clear audit attributes" do
      @model.created_by = 1
      @model.updated_by = 2

      new_model = @model.dup

      expect(new_model.created_by).to be_nil
      expect(new_model.updated_by).to be_nil
    end

    describe "with an real model subclass" do
      it "should not raise an error if nothing has changed" do
        expect { User.new.send(:initialize_dup, User.new) }.to_not raise_error
      end
    end
  end
end
