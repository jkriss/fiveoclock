require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'haml'
require 'tzinfo'
require 'cgi'

before do
  if !settings.respond_to?(:last_check) || Time.now - settings.last_check > 600
    puts "-- updating time zones --"
    set :zones, TZInfo::Country.all.collect { |country| country.zone_info }.flatten.sort { |a,b| a.timezone.period_for_utc(@time).utc_total_offset <=> b.timezone.period_for_utc(@time).utc_total_offset }
    set :last_check, Time.now
  end
end

not_found do
  redirect '/'
end

helpers do
  def place_link(country_tz)
    name = country_tz.timezone.friendly_identifier(true)
    link = "<a href=http://maps.google.com/maps?z=5&t=p&q=#{country_tz.latitude.to_f},#{country_tz.longitude.to_f}+(#{CGI.escape(name)})>#{name}</a>"
  end
end

get '/' do
  @time = Time.now.utc
  @time += params[:offset].to_i if params[:offset]
  
  @other_locations = settings.zones.find_all { |tz| tz.timezone.period_for_utc(@time).to_local(@time).hour == 5 + 12 }
  @fiveoclockhere = @other_locations.delete_at(0)
  # @fiveoclockhere = TZInfo::Timezone.get(@fiveoclockhere.identifier)
  @location = @fiveoclockhere.identifier.split('/').last.gsub("_"," ")
  @afterfive = @fiveoclockhere.timezone.period_for_utc(@time).to_local(@time)
  haml :index
end