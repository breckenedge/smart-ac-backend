class Login
  attr_reader :email, :password

  def initialize(params = {})
    @email = params.fetch('email', '')
    @password = params.fetch('password', '')
***REMOVED***

  def authenticated?
    user && user.authenticate(password)
***REMOVED***

  def user
    User.find_by(email: email)
***REMOVED***

  def user_id
    user&.id
***REMOVED***
***REMOVED***
