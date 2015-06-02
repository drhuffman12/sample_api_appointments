##
# module AppointmentApi::Data
#
#   params:
#     id:         Integer
#     start_time: DateTime
#     end_time:   DateTime
#     first_name: String
#     last_name:  String
#     comments:   String
#
#
# List Appointment(s):
#   params:
#     optional: id, start_time, end_time, first_name, last_name, comments
#
#   e.g.: curl http://localhost:3000/api/v1/appointment_api_data.json
#   e.g.: curl http://localhost:3000/api/v1/appointment_api_data.json -X GET -d "first_name=john"
#
#
# Create a new appointment:
#   params:
#     required: start_time, end_time, first_name, last_name
#     optional: comments
#
#   e.g.: curl http://localhost:3000/api/v1/appointment_api_data.json -d "start_time=2015-06-01T01:23:45.678Z&end_time=2015-06-01T02:23:45.678Z&first_name=john&last_name=doe&comments=foo bar"
#         curl http://localhost:3000/api/v1/appointment_api_data.json -d "start_time=2015-06-03T01:23:45.678Z&end_time=2015-06-03T02:23:45.678Z&first_name=john&last_name=doe&comments=foo bar"
#         curl http://localhost:3000/api/v1/appointment_api_data.json -d "start_time=2015-06-03T11:23:45.678Z&end_time=2015-06-03T12:23:45.678Z&first_name=1&last_name=2&comments=foo bar"
#
#
# Delete a appointment:
#   params:
#     required: id
#
#   e.g.: curl -X DELETE http://localhost:3000/api/v1/appointment_api_data/1.json
#
#
# Update a appointment:
#
#   For the object of the given 'id', use the given value(s) for associated param key(s).
#
#   params:
#     required: id
#     optional: start_time, end_time, first_name, last_name, comments
#
#   e.g.: curl -X PUT http://localhost:3000/api/v1/appointment_api_data/2.json -d "first_name=Johnny&last_name=Smith&comments=corrected name"
#

module AppointmentApi

  class DuplicateKeysError < StandardError
  end

  class Data < Grape::API

    PARAM_KEYS = ['id', 'start_time', 'end_time', 'first_name', 'last_name', 'comments']

    resource :appointment_api_data do

      desc "List Appointment(s)"
      # parameter validation:
      params do
        optional :id, type: Integer
        optional :start_time, type: DateTime
        optional :end_time, type: DateTime
        optional :first_name, type: String
        optional :last_name, type: String
        optional :comments, type: String # Text
      end
      # list:
      get do
        if (PARAM_KEYS & params.keys).count == 0
          appt = Appointment
        else
          appt = Appointment
          appt = appt.where("start_time >= ?", params[:start_time]) if params[:start_time]
          appt = appt.where("end_time <= ?", params[:end_time]) if params[:end_time]
          appt = appt.where("first_name = ?", params[:first_name]) if params[:first_name]
          appt = appt.where("last_name = ?", params[:last_name]) if params[:last_name]
          appt = appt.where("comments LIKE ?", params[:comments]) if params[:comments]
        end
        appt.order('last_name, first_name, start_time, end_time, comments').all
      end

      desc "Create a new appointment"
      # parameter validation:
      params do
        # optional :id, type: Integer
        requires :start_time, type: DateTime
        requires :end_time, type: DateTime
        requires :first_name, type: String
        requires :last_name, type: String
        optional :comments, type: String # Text
      end
      # create:
      post do
        appt = Appointment
        appt = appt.where("start_time = ?", params[:start_time]) if params[:start_time]
        appt = appt.where("end_time = ?", params[:end_time]) if params[:end_time]
        appt = appt.where("first_name = ?", params[:first_name]) if params[:first_name]
        appt = appt.where("last_name = ?", params[:last_name]) if params[:last_name]
        appt = appt.first
        # appt = appt.where("comments = ?", params[:comments]) if params[:comments]
        raise DuplicateKeysError, "record already exists for specified keys" if appt
        Appointment.create!({
                              start_time:params[:start_time],
                              end_time:params[:end_time],
                              first_name:params[:first_name],
                              last_name:params[:last_name],
                              comments:params[:comments]
                            })
      end

      desc "Delete a appointment"
      params do
        requires :id, type: Integer
      end
      delete ':id' do
        Appointment.find(params[:id]).destroy!
      end

      desc "Update a appointment"
      params do
        requires :id, type: Integer
        optional :start_time, type: DateTime
        optional :end_time, type: DateTime
        optional :first_name, type: String
        optional :last_name, type: String
        optional :comments, type: String # Text
      end
      put ':id' do
        appt = Appointment.find(params[:id])
        raise DuplicateKeysError, "record not found for specified key" unless appt
        appt.start_time = params[:start_time] if params[:start_time]
        appt.end_time = params[:end_time] if params[:end_time]
        appt.first_name = params[:first_name] if params[:first_name]
        appt.last_name = params[:last_name] if params[:last_name]
        appt.comments = params[:comments] if params[:comments]
        appt.save
      end

    end

  end
end
