# encoding: UTF-8

require 'sinatra'
require 'data_mapper'
require 'sinatra/flash'
require 'sinatra/reloader'

# include libraries needed for main app
require './models.rb'
require './seed.rb'

# application settings
enable :sessions
set :root, File.dirname(__FILE__)
# set :port, 4567

# set environment variables
SITE_TITLE = "Le Tableau des Pilotes"
SITE_DESCRIPTION = "Le QG des campagnes autruchiennes"




#### Helper Methods ####

helpers do
  # escape html to avoid XSS attacks
  # this adds the h method from the Rack Utils class  include Rack::Utils
  alias_method :h, :escape_html

end

# fake slow net connection for ajax requests
before do
  if request.xhr?
    sleep 1
  end
end

# define routes and actions

# GET '/'
get '/' do
  # set page title for display in browser tab
  @title='Liste des Pilotes'
  
  #set hacky session variables
  session[:autruche] ? session[:autruche]:Autruche.first().id
  session[:campagne] ? session[:campagne]:Campagne.first().id 
  
  # retrieve required data from db
  @autruches = Autruche.all :order => :id.desc
  @campagnes = Campagne.all :order => :id.desc
  
  # display flash messages
  if @autruches.empty?
    flash.now[:error] = 'Aucun pilote dans la base!'
  end
  
  # render view
  erb :home
end
# POST '/'
post '/' do
  session[:autruche] = params[:choix_autruche]
  session[:campagne] = params[:choix_campagne]  
  
  flash[:notice] = "Session parameters set!"

  redirect '/'
end



# GET '/admin'
get '/admin' do
  @title='Gestion Campagne'
  
  erb :admin
end



# GET '/admin/attribution'
# choose which pilot to reward
get '/admin/attribution' do
  @title='Recompenses'
  @page='attribution'
  @autruches = Autruche.all :order=> :callsign.asc
  
  erb :admin
end
# POST '/admin/attribution'
# redirects to individual pilot page to set pilot rewards
post '/admin/attribution' do
  x = params[:choix_autruche]
  uri = "/admin/attribution/#{x}"
  redirect to(uri)
end
# POST '/admin/attribution/:id'
# set pilot rewards
get '/admin/attribution/:id' do
  @page="Attribution"
  @id = params[:id]
  @decorations = Decoration.all :order => :id.asc
  @rewards = Reward
  @autruche = Autruche.get(params[:id])
  @flights = Flight.byAutruche(params[:id])
  
  puts @flights.inspect
  
  # debug
  @flights.each do |f|
    puts f.id  
    if Reward.byFlight(f.id)
      Reward.byFlight(f.id).each do |reward|
        puts Decoration.get(reward.decoration_id).nom
      end       
    end
    
  end
  
  
  erb :attribution
end

# save reward in db
post '/admin/attribution/:id' do
  f = Flight.first(:id => params[:choix_flight])
  puts f.inspect
  m = f.mission_id
  a = f.avatar_id

  n = Reward.first_or_create(:flight_id => f.id,
                             :flight_mission_id => m,
                             :flight_avatar_id => a,
                             :decoration_id => params[:choix_decoration]) 
  redirect back
end



# GET '/admin/mission'
# formulaire pour ajouter une mission à la base
get '/admin/mission' do
  @title='Gestion Mission'
  # load the appropriate js file in template
  @js = "mission.js"
  # retrieve list of all campagnes, latest on top
  @campagnes = Campagne.all :order=>:id.desc
  @selected = params[:campagne]
  
  if !params[:campagne]
    #puts "camp id retrieved from normal GET"
    camp_id = @campagnes[0].id # first campagne in collection is latest
  else
    #puts "camp id retrieved from ajax call"
    camp_id = params[:campagne] # if submitted via Ajax
  end
  # retrieve list of missions for selected campaign
  @missions = Mission.all :campagne_id => camp_id, :order=> :numero.asc
  
  erb :admin_mission , :layout => !request.xhr?
  
end
# POST '/admin/mission/new'
# Enregistrer la mission dans la base
post '/admin/mission' do

  campagne = Campagne.get(params[:campagne]);
  n = campagne.missions.new(:numero => params[:numero],
                            :nom => params[:nom],
                            :briefing => params[:briefing],
                            :debriefing => params[:debriefing]
                            )
  
  campagne.save  
  
  redirect "/admin/mission?campagne=#{params[:campagne]}"
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

# GET '/cr_mission'
# Remplissage du compte rendu de mission
get '/cr_mission' do
  @title='Formulaire Mission'
  @js = "cr_mission.js"

  # only call missions for campaign in session
  @missions = Mission.all(:campagne_id => session[:campagne])
  # only call avatars for pilot in session that is alive (active)
  @avatar = Avatar.first(:autruche_id => session[:autruche], :statut => true)
  
  @montures = Monture.all :order=>:id.asc
  @roles = Role.all :order=>:id.asc
  @flights = Flight.all(:avatar_id => @avatar.id, :order=>:created_at.asc)
  @statuts = StatutFinMission.all :order=>:id.asc
  @revendications = Revendication.all  :order=>:id.asc
  @victoires = Victoire.all :order=>:id.asc
  
  if @flights.empty?
    flash.now[:error] = "Aucune missions effectues par ce pilote"
  end
  
  erb :cr_mission
  
end
# POST '/cr_mission'
# Enregistrer les resultats d'une mission
post '/cr_mission' do

  if params[:temps_vol] == ""
      flight = Flight.first_or_create({:avatar_id => params[:choix_avatar],
                                   :mission_id => params[:choix_mission]
                                   },
                                  {:monture_id => params[:choix_monture],
                                   :role_id => params[:choix_role],
                                   :statut_fin_mission_id => params[:choix_statut]
                                   })
  else
      flight = Flight.first_or_create({:avatar_id => params[:choix_avatar],
                                   :mission_id => params[:choix_mission]
                                   },
                                  {:monture_id => params[:choix_monture],
                                   :role_id => params[:choix_role],
                                   :temps_vol => params[:temps_vol],
                                   :statut_fin_mission_id => params[:choix_statut]
                                   })    
  end
  
  # save flight results
   result_1 = FlightResult.new(:flight_id => flight.id,
                               :revendication_id => params[:revendic_1],
                               :victoire_id => params[:revendic_1],
                               :commentaire => params[:info_1],
                               :flight_avatar_id => params[:choix_avatar],
                               :flight_mission_id => params[:choix_mission]
                                )

   result_1.save

  # set avatar status to false if statut_fin_mission = mort or capture
  

#  if flight
#    flash[:error] = "Mission deja remplie"
#  end

  redirect '/cr_mission'
  
end



get '/admin/avatar' do
  @page='avatar'
  @title='Gestion Avatar'
  
  @autruches = Autruche.all :order=>:callsign.asc
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



post '/admin/avatar' do
  autruche = Autruche.get(params[:choix_autruche])
  
  n = autruche.avatars.new( :prenom => params[:prenom],
                            :nom => params[:nom]
                            )
  
  autruche.save
  
  
  redirect '/admin/avatar'
end

