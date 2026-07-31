module LoginHelpers
  def login_as(user, password: "password123")
    post login_path, params: { email: user.email, password: password }
  end
end

RSpec.configure do |config|
  config.include LoginHelpers, type: :request
end
