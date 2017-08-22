# Handle request testing differences between Rails 4.2 and Rails 5
#
# When support for Rails 4.2 is no longer needed, this can be removed
module DeprecatedRequestMethods

  def get_request(path, params: {}, headers: {})
    if Rails.version.start_with?("5")
      get(path, params: params, headers: headers)
    else
      get(path, params, headers)
    end
  end

  def post_request(path, params: {}, headers: {})
    if Rails.version.start_with?("5")
      post(path, params: params, headers: headers)
    else
      post(path, params, headers)
    end
  end

end
