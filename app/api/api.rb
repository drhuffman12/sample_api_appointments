require 'api_error_handler'

class API < Grape::API
  prefix 'api'
  version 'v1', using: :path
  use ApiErrorHandler
  mount AppointmentApi::Data
end