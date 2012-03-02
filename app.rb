require 'sinatra'
require 'data_mapper'
require 'sinatra/flash'

# include sub-files neede for main app
require './models.rb'

enable :sessions

# set environment variables
SITE_TITLE = "Le Tableau des Pilotes"
SITE_DESCRIPTION = "Le QG des campagnes autruchiennes"


#### Helper Methods ####


helpers do
  # escape html to avoid XSS attacks
  # this adds the h method from the Rack Utils class  include Rack::Utils
  alias_method :h, :escape_html

  # initialize helper table Nation
  def init_nation
    fr = Nation.first_or_create(:pays => 'France')
    gr = Nation.first_or_create(:pays => 'Allemagne')
    us = Nation.first_or_create(:pays => 'Etats Unis')
    it = Nation.first_or_create(:pays => 'Italie')
  end

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
  @title='Gestion Campagne'
  @campagnes=Campagne.all :order=>:id.desc
  @nations=Nation.all :order=>:pays.asc
  
  erb :admin
end

# admin route for campaign manager
get '/admin/campagne' do
  @page='campagne'
  @title='Gestion Campagne'
  @campagnes=Campagne.all :order=>:id.desc
  @nations=Nation.all :order=>:pays.asc
  
  if @campagnes.empty?
    flash[:error] = "Aucune campagne accessible"
  end
  
  erb :admin
end

get '/admin/pays' do
  @page='pays'
  @title='Gestion Campagne'
  @campagnes=Campagne.all :order=>:id.desc
  @nations=Nation.all :order=>:pays.asc
  
  if @nations.empty?
    flash[:error] = "Liste des Nations vide"
  end
  
  erb :admin
end

post '/admin/campagne' do
  n = Campagne.first_or_create(:nom => params[:nom], :descriptif => params[:descriptif]) 
  redirect '/admin/campagne'
end

post '/admin/pays' do
  n = Nation.first_or_create(:pays => params[:pays])
  redirect '/admin/pays'
end
