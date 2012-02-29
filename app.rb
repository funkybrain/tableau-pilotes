require 'sinatra'
require 'data_mapper'
require 'sinatra/flash'

# include sub-files neede for main app
require './models.rb'

enable :sessions

# set environment variables
SITE_TITLE = "Le Tableau des Pilotes"
SITE_DESCRIPTION = "Le QG des campagnes autruchiennes"



# escape html to avoid XSS attacks
# this adds the h method from the Rack Utils class
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end


# define routes and actions

#homepage route - display all notes using GET verb
get '/' do
  @autruches=Autruche.all :order=>:id.desc
  @title='Liste des Pilotes'
  if @autruches.empty?
    flash[:error] = 'Aucun pilote dans la base!'
  end
  erb :home

end

# homepage route for adding new notes using POST verb
post '/' do
  n=Autruche.new
  #the :parameter is the name of the <textarea> defined in the form
  #this is how you can target what field to take from the form
  #and us in your database model
  n.nom = params[:nom]
  n.prenom = params[:prenom]
  n.callsign = params[:callsign]

  if n.save
    flash[:notice] = "Pilote ajout&eacute &agrave la base"
  else
    flash[:error] = "Operation echouee. On est dans la merde"
  end
  redirect '/'
end

# admin route for campaign manager
get '/admin' do
  @campagnes=Campagne.all :order=>:id.desc
  @title='Gestion Campagne'
  erb :admin
end

post '/admin' do
  n=Campagne.new
  n.nom = params[:nom]
  n.descriptif = params[:descriptif]
  n.save
  redirect '/admin'
end
