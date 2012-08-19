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
  
  erb :admin
end

# formulaire pour entrer une mission
get '/admin/mission' do
  @title='Gestion Campagne'
  @missions = Mission.all :order=> :created_at.desc
  @campagnes=Campagne.all :order=>:id.desc
  @page='mission'
  
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
  @title='Gestion Nation'

  @nations=Nation.all :order=>:pays.asc
  
  if @nations.empty?
    flash[:error] = "Liste des Nations vide"
  end
  
  erb :admin
end

get '/admin/grade' do
  @page='grade'
  @title='Gestion Grade'
  @grades = Grade.all :order=>:nom.asc
  @nations = Nation.all :order=>:pays.asc
  
  if @grades.empty?
    flash[:error] = "Liste des Grades vide"
  end
  
  erb :admin
end

get '/admin/autruche' do
  @page='autruche'
  @title='Gestion Autruches'
  
  @autruches=Autruche.all :order=>:callsign.asc
  
  if @autruches.empty?
    flash[:error] = "Liste des pilotes vide"
  end
  
  erb :admin
  
end


get '/mission' do
  @page='xxx'
  @title='xxx'
  
  @missions = Mission.all :order=>:id.asc
  @avatars = Avatar.all :order=>:id.asc
  @montures = Monture.all :order=>:id.asc
  @roles = Role.all :order=>:id.asc
  @flights = Flight.all :order=>:created_at.asc
  @statuts = Statutfinmission.all :order=>:id.asc
  @revendications = Revendication.all  :order=>:id.asc
  @victoires = Victoire.all :order=>:id.asc
  
  if @flights.empty?
    flash[:error] = "Liste des missions vide"
  end
  
  erb :mission
  
end



get '/admin/avatar' do
  @page='avatar'
  @title='Gestion Avatar'
  
  @autruches=Autruche.all :order=>:callsign.asc
  @avatars = Avatar.all :order=> :id.asc
  
  if @avatars.empty?
    flash[:error] = "Liste des avatars vide"
  end
  
  erb :admin
  
end

post '/admin/campagne' do
  n = Campagne.first_or_create(:nom => params[:nom], :descriptif => params[:descriptif]) 
  redirect '/admin/campagne'
end

post '/admin/pays' do
  n = Nation.first_or_create(:pays => params[:pays])
  puts n.inspect
  redirect '/admin/pays'
end

post '/admin/grade' do
  nation = Nation.get(params[:choix_nation])
  n = nation.grades.new(:nom => params[:nom])
  nation.save

  redirect '/admin/grade'
end

post '/admin/autruche' do
  n = Autruche.first_or_create(:callsign => params[:callsign], :prenom => params[:prenom], :nom => params[:nom])
  redirect '/admin/autruche'
end

post '/admin/mission' do
  campagne = Campagne.get(params[:choix_campagne])
  puts campagne.nom
  n = campagne.missions.new(:numero => params[:numero],
                            :nom => params[:nom],
                            :briefing => params[:briefing],
                            :debriefing => params[:debriefing]
                            )
  puts n.inspect
  campagne.save
  
  
  redirect '/admin/mission'
end


post '/admin/avatar' do
  autruche = Autruche.get(params[:choix_autruche])
  
  n = autruche.avatars.new( :prenom => params[:prenom],
                            :nom => params[:nom]
                            )
  
  autruche.save
  
  
  redirect '/admin/avatar'
end

post '/mission' do

  if params[:temps_vol] == ""
      flight = Flight.first_or_create({:avatar_id => params[:choix_avatar],
                                   :mission_id => params[:choix_mission]
                                   },
                                  {:monture_id => params[:choix_monture],
                                   :role_id => params[:choix_role],
                                   :statutfinmission_id => params[:choix_statut]
                                   })
  else
      flight = Flight.first_or_create({:avatar_id => params[:choix_avatar],
                                   :mission_id => params[:choix_mission]
                                   },
                                  {:monture_id => params[:choix_monture],
                                   :role_id => params[:choix_role],
                                   :temps_vol => params[:temps_vol],
                                   :statutfinmission_id => params[:choix_statut]
                                   })    
  end


#  if flight
#    flash[:error] = "Mission deja remplie"
#  end
  puts flight.inspect
  puts flight.saved?
  
  redirect '/mission'
  
end
