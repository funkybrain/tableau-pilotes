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
AUTRUCHES = Autruche.all :order => :callsign.asc 
CAMPAGNES = Campagne.all :order => :id.desc
  
# HELPER METHODS

helpers do
  # escape html to avoid XSS attacks
  # this adds the h method from the Rack Utils class  include Rack::Utils
  alias_method :h, :escape_html

  def get_plane_img_src(monture_id, nation_id)
    path_prefix = "../img/icons/avions/"
    nation_slug =  Nation.get(nation_id).slug + "/"
    monture_name = Monture.get(monture_id).modele.gsub!("-", "").downcase + ".png"
    return image_src = path_prefix + nation_slug + monture_name
  end

  def get_grade_img_src(grade_id)
    path_prefix = "../img/icons/grades/"
    nation_slug =  Grade.get(grade_id).nation.slug + "/"
    grade_img_src = Grade.get(grade_id).img_src
    return image_src = path_prefix + nation_slug + grade_img_src
  end
end

### TODO create helper methods used in views a lot e.g. to display icons

# debug clear session
get '/clear' do
    session[:autruche] = nil
    session[:campagne] = nil
    puts "session cleared"
end

# fake slow net connection for ajax requests
before do
  if request.xhr?
    sleep 1
  end  
end

# set hacky session variable
before ('/') do  
  #if session coookies are empty, set them
  session[:autruche] ||= Autruche.get(1).id
  session[:campagne] ||= Campagne.get(2).id

end

# DEFINE ROUTES AND ACTIONS

get '/' do
  # set page title for display in browser tab
  @title='Liste des Pilotes'
  # @js = "home.js"
      
  # retrieve data to set session parameters
  @autruches = Autruche.all :order => :id.desc
  @campagnes = Campagne.all :order => :id.desc
  
  # get nation slug based on current campaign
  @nation = Nation.get(Campagne.get(session[:campagne]).nation_id).slug + '/'

  # update TabGen - this is a bad hack because i still havent figured out
  # when i should update TabGen.
  if Flight.byAutruche(session[:autruche]).byCampaign(session[:campagne]).count > 0
    TabGen.updateTable(session[:autruche], session[:campagne])
    # get all flights for campaign in session
    @tabgen = TabGen.all(:campagne_id => session[:campagne])
  else
    flash.now[:error] = 'Aucunes missions dans cette campagne!'
  end



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
  
  flash[:notice] = "Choix Autruche et/ou Campagne validé!"

  redirect back
end


### ATTRIBUTIONS MEDAILLES ET CITATIONS:

# choose which pilot to reward
get '/admin/attribution' do
  @title='Recompenses'
  @page='attribution'
  @autruches = Autruche.all :order=> :callsign.asc
  
  erb :admin_attrib_choix
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
  
  erb :admin_attrib_deco
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
    # retrieved from normal GET"
    camp_id = @campagnes[0].id # first campagne in collection is latest
  else
    # retrieved from ajax call"
    camp_id = params[:campagne] # if submitted via Ajax
  end
  # retrieve list of missions for selected campaign
  @missions = Mission.all :campagne_id => camp_id, :order=> :numero.asc
  
  
  erb :admin_mission , :layout => !request.xhr?
  
end

# Enregistrer la mission dans la base
post '/admin/mission' do

  #TODO: don't ask for mission numero, auto-increment based on last numero

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
  
  erb :admin_campagne
end

post '/admin/campagne' do

  # TODO: before creating a new campaign, set all current campaign avatars to inactive
  # and then set last campaign to inactive, and new campaign to active
  n = Campagne.first_or_create(:nom => params[:nom],
   :descriptif => params[:descriptif],
   :nation_id => params[:choix_nation])

  redirect '/admin/campagne'
end

### AJOUTER UN PAYS

get '/admin/nation' do
  @page='pays'
  @title='Gestion Nation'

  @nations=Nation.all :order=>:pays.asc
  
  if @nations.empty?
    flash[:error] = "Liste des Nations vide"
  end
  
  erb :admin_nation
end

post '/admin/pays' do
  n = Nation.first_or_create(:pays => params[:pays])
  puts n.inspect
  redirect '/admin/nation'
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
  
  erb :admin_autruche
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
  
  if @avatar == nil
    # aucun avatar actif pour cette autruche
    # balancer un message d'erreur et rediriger sur la creation d'avatar
    flash[:error] = "Aucun avatar actif pour ce pilote"
    redirect '../admin/avatar'
  end


  # retrieve all flights associated with current avatar for current campagne
  # @flights = Flight.all(:avatar_id => @avatar.id,
  #                       :order=>:created_at.asc)
  #                  .all(Flight.mission.campagne.id => session[:campagne])
  # this last line above is very dirty, need to find something more elegant
  # I'm getting the sinking sensation that my data structure is really shit

  # retieve all flights for current pilot and campaign
  @flights = Flight.byAutruche(session[:autruche]).byCampaign(session[:campagne])

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
  puts "tab gen updated"
  # bug - yhis doesnt work because the revendication is an ajax call
  # hence this never gets called except when adding the basic info


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

=begin TODO: add rules for avatar lifecycle
* canot create avatar for pilot who still has a live one
* have flash message on home page if there is a pilot with no avatar
in current campaign
* crap, what happend if warpig wants to rescusite an avatr?
* how do you give rewards to a dead avatar? current logic in cr-mission is flawed?
  
=end

get '/admin/avatar' do

  @title='Gestion Avatar'

  @campagne = Campagne.get(session[:campagne])
  @autruche = Autruche.get(session[:autruche])

  # @avatars = Avatar.byAutruche(session[:autruche])
  @old_avatars = Avatar.byAutruche(session[:autruche]).byCampaign(session[:campagne])
  @new_avatar = Avatar.notFlown(session[:autruche])
  @avatars = @old_avatars + @new_avatar

  # check if all avatars are inactive to enable adding a new one
  @can_add = true
  @avatars.each do |a|
   if a.statut == true
    @can_add = false
   end 
  end  

  if @avatars.empty?
    flash.now[:error] = "Aucun avatar pour ce pilote et/ou cette campagne"
  end
  
  erb :admin_avatar
end

post '/admin/avatar' do

  autruche = Autruche.get(session[:autruche])
  nationalite = Campagne.get(session[:campagne]).nation_id

  n = autruche.avatars.new( :prenom => params[:prenom], :nom => params[:nom], :nation_id => nationalite )
  autruche.save

  #TODO: automatically give this new avatar its starting (lowest) Grade  


  redirect '/admin/avatar'
end

get '/admin/avatar/:id' do
  @title='Modification Avatar'
  @id = params[:id]
  puts @id

  @avatar = Avatar.get(params[:id])

  erb :admin_avatar_edit
end  

post '/admin/avatar/:id' do

  n = Avatar.get(params[:id]).update( :prenom => params[:prenom], :nom => params[:nom], :statut => params[:statut] )

  redirect '/admin/avatar'
end  


### PALMARES PILOTE

get '/pilote' do

  # get all missions for campagne and autruche in session
  @flights = Flight.byAutruche(session[:autruche]).byCampaign(session[:campagne]).all(:order => :avatar_id.asc)
  @nation = Nation.get(Campagne.get(session[:campagne]).nation_id).slug + '/'


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

  @m_id = params[:id]
  # user must choose a mission
  @missions = Mission.all(:campagne_id => session[:campagne])
  # get nation slug to display correct icons
  @nation = Campagne.get(session[:campagne]).nation_id
  
  if params[:id] == "select"
    @display_table = false

  else
    # get all flights for mission :id and campaign in session
    @flights = Flight.byCampaign(session[:campagne]).byMission(params[:id]).all()
    # display table for mission
    @display_table = true
    @mission =  Mission.get(@m_id).numero.to_s + ": " + Mission.get(@m_id).nom
   
    @pilot_table = []

    def createPilotTable
      # Too much logic in the view, it's horrible
      # pre-process everthing here, i.e. store all
      # the table row details in an array of hashes and call in view
      
      @flights.each do |f|
        pilot = Hash.new
        grade =  f.avatar.promotions(:mission_id => @mission_id).grade
        if grade.empty?
         grade = f.avatar.promotions.first().grade
        end 
        pilot["grade"]      = grade.nom
        pilot["grade_img"]  = get_grade_img_src(grade.id)
        pilot["callsign"]   = f.avatar.autruche.callsign
        pilot["monture_img"]= get_plane_img_src(f.monture_id, @nation)
        pilot["vic_conf"]   = f.flight_results.victoires.count(:id => 1)
        pilot["vic_part"]   = f.flight_results.victoires.count(:id => 2)
        pilot["temps_vol"]  = f.tps_vol_hr.to_s + "h" + f.tps_vol_min.to_s
        pilot["statut"]     = f.statut_fin_mission.statut
        pilot["role"]       = Role.get(f.role_id).type
        pilot["deco"]       = "" # tbd-> f.rewards.each {|r| r.decoration.nom}

        @pilot_table << pilot
      end
    end
    createPilotTable

  end

  erb :campagne
end

post '/campagne' do
  # return the mission id and pass to the get /campagne
  id = params[:id]

  uri = "/campagne?id=#{id}"
  redirect to(uri)
end  

