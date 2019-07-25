require 'csv'

class DeviceReadingsChartDataPresenter
  include Enumerable

  attr_reader :device, :term, :limit

  def initialize(device:, term: :day)
    @device = device
    @term = term
  end

  delegate :each, to: :results

  def results
    ActiveRecord::Base.connection.raw_connection
      .exec_params(query, [from_time, Time.current, device.id])
  end

  def from_time
    case term
    when 'this_week'
      1.week.ago
    when 'this_month'
      1.month.ago
    when 'this_year'
      1.year.ago
    else
      1.day.ago
    end
  end

  def to_csv
    ::CSV.generate do |csv|
      csv << [
        'recorded_at',
        'temperature_c',
        'humidity_%',
        'carbon_monoxide_ppm'
      ]

      results.map do |device_message|
        csv << device_message.values
      end
    end
  end

  private

  def query
    @@query ||= File.read(File.expand_path('./sql/device_readings_chart_data_presenter.sql'))
  end
end
