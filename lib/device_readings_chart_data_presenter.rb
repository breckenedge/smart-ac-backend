require 'csv'

class DeviceReadingsChartDataPresenter
  include Enumerable

  attr_reader :device, :term, :limit

  def initialize(device:, term: :day)
    @device = device
    @term = term
***REMOVED***

  delegate :each, to: :results

  def results
    ActiveRecord::Base.connection.raw_connection
      .exec_params(query, ***REMOVED***from_time, Time.current, device.id])
***REMOVED***

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
  ***REMOVED***
***REMOVED***

  def to_csv
    ::CSV.generate do |csv|
      csv << ***REMOVED***
        'recorded_at',
        'temperature_c',
        'humidity_%',
        'carbon_monoxide_ppm'
      ]

      results.map do |device_message|
        csv << device_message.values
    ***REMOVED***
  ***REMOVED***
***REMOVED***

  private

  def query
    @@query ||= File.read(File.expand_path('./sql/device_readings_chart_data_presenter.sql'))
***REMOVED***
***REMOVED***
