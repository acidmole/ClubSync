require 'nokogiri'
require 'open-uri'
require 'json'

class FetchEventsJob
  include Sidekiq::Job
  sidekiq_options queue: :default

  def perform(*args)
    Rails.logger.info "Fetching myClub events"

    # URL to fetch the data
    url = "https://ebt.myclub.fi/groups/41620/event_embeds/26739?token=8ac9ab8f581cf1403ee14076b2daec841656da5a"

    # Parse the HTML
    doc = Nokogiri::HTML(URI.open(url))
    data_events_json = JSON.parse(doc.at_css('#events')['data-events'])

    counter = 0
    unless data_events_json.nil?
      data_events_json.each do |event|
        event_div = doc.at_css("div.event[data-event-id='#{event['id']}']")
        date = finnish_date_to_date(event_div.at_css('span.day').text.strip, event['month'].to_date.year)
        next if date < Date.today
        time = event_div.at_css('span.time').text.strip
        starts_at = Time.parse("#{date} #{time}")
        Event.find_or_create_by(id: event['id']) do |e|
          e.name = event['name']
          e.venue = event['venue']
          e.starts_at = starts_at
          counter += 1
        end
      end
    end
    Rails.logger.info "Fetched myClub events, new events: #{counter}"
  end

  def finnish_date_to_date(finnish_date, year)
    return nil if finnish_date.nil?
    date_without_weekday = finnish_date.split(' ')[1]
    day, month = date_without_weekday.split('.').map(&:to_i)
    Date.new(year, month, day)
  end
end
