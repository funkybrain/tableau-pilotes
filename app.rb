# encoding: UTF-8

require 'sinatra'
require 'data_mapper'
require 'sinatra/flash'
require 'sinatra/reloader'

# include libraries needed for main app
require './db_models.rb'
require './seed.rb'
require './tableau_general'

# application settings
enable :sessions
set :root, File.dirname(__FILE__)
# set :port, 4567

# set environment variables
SITE_TITLE ||= "Le Tableau des Pilotes"
SITE_DESCRIPTION ||= "Le QG des campagnes autruchiennes"

# HELPER METHODS

helpers do
  # escape html to avoid XSS attacks
  # this adds the h method from the Rack Utils class  include Rack::Utils
  alias_method :h, :escape_html

end

# debug clear session
get '/clear' do
    session[:autruche] = nil
    session[:campagne] = nil
    puts "session cleared"
end

# fake slow net connection for ajax requests
# and set hacky session variable

before do
  if request.xhr?
    sleep 1
  end  
  
  #if session coookies are empty, set them
  session[:autruche] ||= Autruche.first().id
  session[:campagne] ||= Campagne.first().id
  # debug
  # puts "autruche: " + session[:autruche].to_s
  # puts "campagne: " + session[:campagne].to_s
end

# DEFINE ROUTES AND ACTIONS

get '/' do
  # set page title for display in browser tab
  @title='Liste des Pilotes'
  @js = "home.js"
      
  # retrieve data to set session parameters
  @autruches = Autruche.all :order => :id.desc
  @campagnes = Campagne.all :order => :id.desc
  

  # get all flights for campaign in session
  @tabgen = TabGen.all()

  # display flash messages
  if @autruches.empty?
    flash.now[:error] = 'Aucun pilote dans la base!'
  end
  
  # render view
  erb :home
end

# set active pilot and campaign
post '/' do
  session[:autruche] = params[:choix_autruche]
  session[:campagne] = params[:choix_campagne]  
  
  flash[:notice] = "Session parameters set!"

  redirect '/'
end

# Load main admin page
get '/admin' do
  @title='Gestion Campagne'
  @js = "admin.js"
  
  erb :admin
end


### ATTRIBUTIONS MEDAILLES ET CITATIONS:

# choose which pilot to reward
get '/admin/attribution' do
  @title='Recompenses'
  @page='attribution'
  @autruches = Autruche.all :order=> :callsign.asc
  
  erb :admin
end

# redirects to individual pilot page to set pilot rewards
post '/admin/attribution' do
  x = params[:choix_autruche]
  uri = "/admin/attribution/#{x}"
  redirect to(uri)
end

# set individual pilot rewards
get '/admin/attribution/:id' do
  @page="Attribution"
  @id = params[:id]
  @decorations = Decoration.all :order => :id.asc
  @rewards = Reward
  @autruche = Autruche.get(params[:id])
  @flights = Flight.byAutruche(params[:id])
  
  
  # debug
  @flights.each do |f|
      
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


### AJOUTER MISSIONS A UNE CAMPAGNE:

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

### AJOUTER UNE CAMPAGNE:

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

post '/admin/campagne' do
  n = Campagne.first_or_create(:nom => params[:nom], :descriptif => params[:descriptif]) 
  redirect '/admin/campagne'
end

### AJOUTER UN PAYS

get '/admin/pays' do
  @page='pays'
  @title='Gestion Nation'

  @nations=Nation.all :order=>:pays.asc
  
  if @nations.empty?
    flash[:error] = "Liste des Nations vide"
  end
  
  erb :admin
end

post '/admin/pays' do
  n = Nation.first_or_create(:pays => params[:pays])
  puts n.inspect
  redirect '/admin/pays'
end

### AJOUTER UN GRADE

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

post '/admin/grade' do
  nation = Nation.get(params[:choix_nation])
  n = nation.grades.new(:nom => params[:nom])
  nation.save

  redirect '/admin/grade'
end

### AJOUTER UNE AUTRUCHE

get '/admin/autruche' do
  @page='autruche'
  @title='Gestion Autruches'
  
  @autruches=Autruche.all :order=>:callsign.asc
  
  if @autruches.empty?
    flash[:error] = "Liste des pilotes vide"
  end
  
  erb :admin
end

post '/admin/autruche' do
  n = Autruche.first_or_create(:callsign => params[:callsign], :prenom => params[:prenom], :nom => params[:nom])
  redirect '/admin/autruche'
end

### AJOUTER UN COMPTE RENDU DE MISSION

# Remplissage du compte rendu de mission
get '/cr_mission' do
  @title='Formulaire Mission'
  @js = "cr_mission.js"

  # only call missions for campaign in session
  @missions = Mission.all(:campagne_id => session[:campagne], :order=>:numero.desc)
  
  # only call avatars for pilot in session that is alive (active)
  @avatar = Avatar.first(:autruche_id => session[:autruche], :statut => true)
  
  # retrieve all flights associated with current avatar for current campagne
  @flights = Flight.all(:avatar_id => @avatar.id,
                        :order=>:created_at.asc)
                   .all(Flight.mission.campagne.id => session[:campagne])
  # this last line above is very dirty, need to find something more elegant
  # I'm getting the sinking sensation that my data structure is really shit

  @montures = Monture.all :order=>:id.asc
  @roles = Role.all :order=>:id.asc
  @statuts = StatutFinMission.all :order=>:id.asc
  @revendications = Revendication.all  :order=>:id.asc
  @victoires = Victoire.all :order=>:id.asc
  
  if @flights.empty?
    flash.now[:error] = "Aucunes missions effectues par ce pilote"
  end
  
  erb :cr_mission  
end


# Enregistrer les resultats d'une mission
post '/cr_mission' do
  
  # trim leading zeros on integers otherwise you will get an error

  flight = Flight.first_or_create({:avatar_id => params[:choix_avatar],
                                   :mission_id => params[:choix_mission]
                                   },
                                  {:monture_id => params[:choix_monture],
                                   :role_id => params[:choix_role],
                                   :tps_vol_hr => params[:tps_vol_hr],
                                   :tps_vol_min => params[:tps_vol_min],
                                   :statut_fin_mission_id => params[:choix_statut]
                                   })    
  

  #TODO: set avatar status to false if statut_fin_mission = mort or capture
  # check warpigs message on subject

  # update TabGen to account for new missions
  updateOK = TabGen.updateTable(session[:autruche], session[:campagne])
  puts updateOK.inspect




  if flight
    flash[:error] = "Mission deja remplie"
  end

  redirect '/cr_mission'  
end


# Enregistrer les revendications liées à une mission
post '/cr_mission/revendication' do
  #
  #params[:revendication].each_index do |i|
  #  print params[:choix_mission] + "-"
  #  print params[:choix_avatar] + "-"
  #  print params[:revendication][i] + "-"
  #  print params[:info_complementaire][i] + "-"
  #  print params[:victoire][i]
  #  puts ""
  #end
  
  @flight = Flight.first(:avatar_id => params[:choix_avatar],
                        :mission_id=> params[:choix_mission])
  
 
  params[:revendication].each_index do |i|
    fr = FlightResult.create(:flight_avatar_id => params[:choix_avatar],
                             :flight_mission_id => params[:choix_mission],
                             :flight_id => @flight.id,
                             :revendication_id => params[:revendication][i],
                             :commentaire => params[:info_complementaire][i],
                             :victoire_id => params[:victoire][i])  
    end

  redirect '/cr_mission'  
end


### AJOUTER UN AVATAR

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

post '/admin/avatar' do
  autruche = Autruche.get(params[:choix_autruche])
  
  n = autruche.avatars.new( :prenom => params[:prenom],
                            :nom => params[:nom]
                            )
  
  autruche.save
  
  
  redirect '/admin/avatar'
end

### PALMARES PILOTE

get '/pilote' do

  # get all missions for campagne and autruche in session
  @flights = Flight.byAutruche(session[:autruche]).byCampaign(session[:campagne]).all(:order => :avatar_id.asc)
  
  # find all unique avatars in returned collection and store their id's in an array @unique_avatars
  @unique_avatars = @flights.uniq {|x| x.avatar_id}.inject([]) do |result, element|
  result << element.avatar_id
  end
  
  # debug
  # print @unique_avatars
  # puts ""
  # @flights.each {|f| p f}
  # @unique_avatars.each do |aid|
  #   puts aid
  #   print @flights.find_all{ |f| f.avatar_id == aid }.each do |f|
  #     puts f.avatar_id
  #     puts f.inspect
  #   end
  # end    

  erb :pilote
end

### SUIVI CAMPAGNE

get '/campagne' do
  # get all missions for campagne in session
  # for now hardwire mission, later must be selectable as dropdown
  @missnum = 1
  @flights = Flight.byCampaign(session[:campagne]).byMission(@missnum).all(:order => :avatar_id.asc)
  
  erb :campagne
end


