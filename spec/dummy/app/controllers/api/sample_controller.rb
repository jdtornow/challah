class Api::SampleController < Api::ApplicationController

  # GET /challah/api
  def index
    render json: {
      message: "Success!",
      user: {
        id: current_user.id,
        name: current_user.name
      }
    }
  end

end
