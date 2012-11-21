require './db_helpers.rb'
require './tableau_general.rb'

# setup db connection
# DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/autruche.db")
# To pull db from heroku heroku db:pull postgres://localhost/project.db
DataMapper::setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/autruche.db")

# exception handling
DataMapper::Model.raise_on_save_failure = true



# Table: Autruche
# ---------------
# Registers all AV pilots
# ------------------------------
# id | nom | prenom | callsign |
# ------------------------------
class Autruche

# insures model persistence  
  include DataMapper::Resource

# resource definitions  
  property :id,         Serial    #auto-increment integer key
  property :nom,        String,  :required => true
  property :prenom,     String,  :required => true
  property :callsign,   String,  :required => true, :default => "AV_Trouduc"
  property :created_at,  DateTime  # handled automagically thanks to dm-timestamp

# associations  
  has n, :avatars
  
end




# Table: Avatar
# -------------
# Liste des avatars associŽs aux pilotes
# ----------------------------------------
# id | nom | prenom | statut | autruche_id
# ----------------------------------------
class Avatar 
  include DataMapper::Resource
  
  property :id,         Serial    #auto-increment integer key
  property :nom,        String,  :required => true
  property :prenom,     String,  :required => true
  # if statut false => avatar est mort
  property :statut,     Boolean, :required => true, :default => true
  property :created_at,  DateTime
  
  belongs_to :autruche #defaults to :required=>true
  
  has n, :flights
  has n, :promotions
  
  # these relatinships help make direct calls to e.g. avatar.missions
  # they don't create additional columns in the table
  has n, :missions,    :through => :flights
  has n, :grades,      :through => :promotions
 
end



# Table: Campagne
# -------------
# Liste des campagnes
# ---------------------------------
# id | nom | descriptif | isactive 
# ---------------------------------
class Campagne
  include DataMapper::Resource
  
  property :id,         Serial    #auto-increment integer key
  property :nom,        Text,    :required => true
  property :descriptif, Text,    :required => false, :default => "Pas de descriptif"
  # set isactive => true to set active campaign (used to display  correct data on homepage)
  property :isactive,   Boolean, :required => false, :default => false
  property :created_at, DateTime

  has n, :missions
  
end


# Table: Mission
# -------------
# Liste des missions associŽes aux campagnes
# -----------------------------------------------------------
# id (PK)| numero | nom | briefing | debriefing | campagne_id 
# -----------------------------------------------------------
class Mission
  include DataMapper::Resource
  
  property :id,         Serial    #auto-increment integer key
  property :numero,     Integer, :required => true
  property :nom,        String,  :required => true
  property :briefing,   Text,    :required => false, :default => "Pas de briefing"
  property :debriefing, Text,    :required => false, :default => "Pas de debriefing"
  property :created_at,  DateTime
  
  belongs_to :campagne

  has n, :flights
  has n, :avatars, :through => :flights
 
end


# Table: Flight
# -------------
# use it to store meta-data about an avatar going on a mission
# ----------------------------------------------------------------------------------------------
# id | temps_vol | id_avatar (CK)| id_mission (CK)| id_role | id_statut_fin_mission | id_monture
# ----------------------------------------------------------------------------------------------
class Flight
  include DataMapper::Resource
  
  # define properies and keys
  property :id,          Serial
  property :tps_vol_hr,  Integer, :required => true, :default => 0
  property :tps_vol_min, Integer, :required => true, :default => 0
  
  property :created_at,  DateTime
  property :updated_at,  DateTime
  
  belongs_to :avatar,  :key => true
  belongs_to :mission, :key => true  
  belongs_to :role
  belongs_to :statut_fin_mission
  belongs_to :monture
  
  has n, :flight_results
  has n, :rewards
  
  # remember that you can chain these methods for more complex queries
  # retrieve a collection of all flights by a given pilot (i.e. all his avatars)
  def self.byAutruche(id)
    all(Flight.avatar.autruche.id => id)
  end

  # retrieve all flights for campaign in session
  def self.byCampaign(campaignId)
    all(Flight.mission.campagne.id => campaignId)
  end
  
end


# Table: FlightResult
# -------------------
# Stores the revendication/victoire pair submitted in formulaire pilote
# for each Flight (i.e. for each avatar/mission pair)
# ---------------------------------------------------------------
# id | commentaire | revendication_id | victoire_id | flight_id |
# ---------------------------------------------------------------
class FlightResult
  
  include DataMapper::Resource
  
  property :id,           Serial
  property :commentaire,  Text, :required => false, :length => 255
  property :created_at,   DateTime
  
  belongs_to :revendication
  belongs_to :victoire
  belongs_to :flight

  # retrieve a collection of all results associate with a given flight
  def self.byFlight(id)
    all(flight.id => id)
  end

  
end


# Table: Reward
# -------------
# enregistre l'attribution de medailles et citations pour chaque pilote
# ------------------------------
# id | id_flight | id_decoration
# ------------------------------
class Reward
  include DataMapper::Resource
  
  property :id,          Serial
  property :created_at,  DateTime
  property :updated_at,  DateTime
  
  belongs_to :flight
  belongs_to :decoration
  
  # retrieve a collection of all rewards associate with a given flight
  def self.byFlight(id)
    all(Reward.flight.id => id)
  end

end



# Table: Promotion
# -------------------
# defines the join between avatars and grades
# use it to store meta-data about when an avatar gets a promotion
# ---------------------------------------------------------------
# id | avatar_id | grade_id |
# ---------------------------------------------------------------
class Promotion
  include DataMapper::Resource

  property :id,             Serial
  property :created_at,     DateTime
  property :updated_at,     DateTime
  
  belongs_to :avatar, :key => true
  belongs_to :grade,  :key => true
  
end



# call after all models and relationships have been defined
DataMapper.finalize

# call to create tables (migration is automatic)
# auto upgarde does not destroy schema
DataMapper.auto_upgrade!

# auto migrate destroys and rebuilds schema
# DataMapper.auto_migrate!
