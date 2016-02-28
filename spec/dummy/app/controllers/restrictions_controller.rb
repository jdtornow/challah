# @private
# This controller is only used for testing purposes, it does not actually get used outside of test.
class RestrictionsController < ApplicationController
  signin_required                 only: [ :blah ]
  before_action :signin_required, only: [ :edit ]
  restrict_to_authenticated       only: [ :show ]

  def index
    current_user

    head :ok
  end

  def show
    head :ok
  end

  def edit
    head :ok
  end

  def blah
    head :ok
  end
end
