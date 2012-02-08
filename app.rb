require 'sinatra'
require 'data_mapper'
require 'sinatra/flash'

enable :sessions

# set environment variables
SITE_TITLE = "Le Tableau des Pilotes"
SITE_DESCRIPTION = "Le QG des campagnes autruchiennes"

# setup db connection
# DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/autruche.db")
# To pull db from heroku heroku db:pull postgres://localhost/project.db
DataMapper::setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/autruche.db")

# define model
class Autruche
  include DataMapper::Resource # insures model persistence
  
  property :id,         Serial    #auto-increment integer key
  property :nom,        String,  :required => true, :default => false
  property :prenom,     String,  :required => true, :default => false
  property :callsign,   String,  :required => true, :default => false
  property :created_at,  DateTime  # handled automagically thanks to dm-timestamp
 
  
end

# call after all models and relationships have been defined
DataMapper.finalize
# call to create tables (migration is automatic)
DataMapper.auto_upgrade!

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
  #the parameter :content is the name of the <textarea> defined in the form
  #this is how you can target what field to take from the form
  #and us in your database model
  n.nom = params[:nom]
  n.prenom = params[:prenom]
  n.callsign = params[:callsign]

#  n.created_at = Time.now
 
  if n.save
    flash[:notice] = "Pilote ajout&eacute &agrave la base"
  else
    flash[:error] = "Operation echouee. On est dans la merde"
  end
  redirect '/'
end