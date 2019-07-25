class Login
  attr_reader :email, :password

  def initialize(params = {})
    @email = params.fetch('email', '')
    @password = params.fetch('password', '')
  end

  def authenticated?
    user && user.authenticate(password)
  end

  def user
    User.find_by(email: email)
  end

  def user_id
    user&.id
  end
end
