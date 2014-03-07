require 'spec_helper'

module Challah
  describe "Routes" do
    describe "GET /sign-in" do
      it "routes properly" do
        expect(:get => "/sign-in").to route_to("sessions#new")
      end
    end

    describe "POST /sign-in" do
      it "routes properly" do
        expect(:post => "/sign-in").to route_to("sessions#create")
      end
    end

    describe "GET /sign-out" do
      it "routes properly" do
        expect(:get => "/sign-out").to route_to("sessions#destroy")
      end
    end
  end
end
