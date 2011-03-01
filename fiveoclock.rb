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

get '/' do
  @time = Time.now.utc
  @time += params[:offset].to_i if params[:offset]
  
  @fiveoclockhere = settings.zones.find { |tz| tz.timezone.period_for_utc(@time).to_local(@time).hour == 5 + 12 }
  # @fiveoclockhere = TZInfo::Timezone.get(@fiveoclockhere.identifier)
  @location = @fiveoclockhere.identifier.split('/').last.gsub("_"," ")
  @afterfive = @fiveoclockhere.timezone.period_for_utc(@time).to_local(@time)
  haml :index
end