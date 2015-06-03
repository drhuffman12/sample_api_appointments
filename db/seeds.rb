require 'smarter_csv'

def load_appointments(file_path, zone_name, verbose_errors)
  when_started = DateTime.now
  when_started_str = "Started: #{when_started}"
  log_path = file_path + '.log'
  error_path = file_path + '.err'
  errored_qty = 0
  loaded_qty = 0
  begin
    File.delete(log_path) if File.exists?(log_path)
    File.delete(error_path) if File.exists?(error_path)
    File.open(log_path, 'w') {|f| f << when_started_str }
    File.open(error_path, 'w') {|f| f << when_started_str }

    csv_data = SmarterCSV.process(file_path)
    record_count = csv_data.length

    File.open(log_path, 'a') {|f| f << "\n\nLoading..." }
    csv_data.each do |data_for_record|
      begin

        data_for_record[:start_time] = Time.use_zone(zone_name) { Time.zone.parse(data_for_record[:start_time]) }
        data_for_record[:end_time] = Time.use_zone(zone_name) { Time.zone.parse(data_for_record[:end_time]) }

        created = Appointment.create!(data_for_record)
        loaded_qty += 1
        File.open(log_path, 'a') {|f| f << "\n\n#{data_for_record.inspect}" }
      rescue => e
        errored_qty += 1
        msg = "\n\n" + '='*80 + "\n== Error:#{e.message}"
        msg << "\n\n== Data:\n#{data_for_record}"
        msg << ("\n\n== Error Backtrace:\n" + e.backtrace.join("\n")) if verbose_errors

        File.open(error_path, 'a') {|f| f << msg }
      end
    end
  rescue => e
    errored_qty += 1
    msg = ("\n\n" + '='*80 + "\n== Error:#{e.message}")
    msg << ("\n\n== Error Backtrace:\n" + e.backtrace.join("\n") + "\n") if verbose_errors
    File.open(error_path, 'a') {|f| f << msg }
  end

  msg = "\n\n#{loaded_qty} out of #{record_count} loaded. #{errored_qty} errored."
  File.open(log_path, 'a') { |f| f.write(msg) }
  File.open(error_path, 'a') { |f| f.write(msg) }

  File.open(log_path, 'a') { |f| f.write("\n\nWarning! Not all data loaded! See '#{error_path}'.") } if (loaded_qty < record_count)

  when_finished = DateTime.now
  when_finished_str = "\n\nFinished: #{when_finished}"
  when_duration = ((when_finished - when_started) * 24.0 * 60 * 60).to_f
  when_duration_str = "\nDuration: #{format("%.4f", when_duration)} seconds\n"

  File.open(log_path, 'a') {|f| f << when_finished_str }
  File.open(error_path, 'a') {|f| f << when_finished_str }
  File.open(log_path, 'a') {|f| f << when_duration_str }
  File.open(error_path, 'a') {|f| f << when_duration_str }
end

zone_name = 'Hawaii' # Set to applicable timezone. For testing, we are setting to 'Hawaii', since we set "config.time_zone = 'Eastern Time (US & Canada)'" in 'config/application.rb'.
verbose_errors = false

begin
  file_path = 'db/appointments.yr2013.csv'
  load_appointments(file_path, zone_name, verbose_errors)

  file_path = 'db/appointments.yr2015.csv'
  load_appointments(file_path, zone_name, verbose_errors)
rescue => e
  msg = ("\n== Error:#{e.message}")
  msg << ("\n\n== Error Backtrace:\n" + e.backtrace.join("\n") + "\n")
  puts msg
end
