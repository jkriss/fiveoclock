require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'haml'
require 'tzinfo'

before do
  @zones = TZInfo::Timezone.all.sort { |a,b| a.period_for_utc(@time).utc_total_offset <=> b.period_for_utc(@time).utc_total_offset }
end

get '/' do
  @time = Time.now.utc
  
  @fiveoclockhere = @zones.find { |tz| tz.period_for_utc(@time).to_local(@time).hour == 5 + 12 }
  # @fiveoclockhere = TZInfo::Timezone.get(@fiveoclockhere.identifier)
  @location = @fiveoclockhere.identifier.split('/').last.gsub("_"," ")
  @afterfive = @fiveoclockhere.period_for_utc(@time).to_local(@time)
  haml :index
end