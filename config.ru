# ok so putting the './' in front of the app name is SUPER CRITICAL
# assume the server has no clue where his root is and where to find the file

require './app'
# require 'bowtie'

#map "/admin" do
#  run Bowtie::Admin
#end

map '/' do
  run Sinatra::Application
end
