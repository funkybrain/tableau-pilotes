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
  property :id,          Serial  # i think i have to set :key=> true here to solve my problems...
  property :temps_vol,   Time, :required => false, :default => "00:00"
  property :created_at,  DateTime
  property :updated_at,  DateTime
  
  belongs_to :avatar,  :key => true
  belongs_to :mission, :key => true  
  belongs_to :role
  belongs_to :statut_fin_mission
  belongs_to :monture
  
  has n, :flight_results
  has n, :rewards
  
  # remember that you ca chain these methods for more complex queries
  # retrieve a collection of all flights by a given pilot (i.e. all his avatars)
  def self.byAutruche(id)
    all(Flight.avatar.autruche.id => id)
  end
  
end



# Table: Reward
# -------------
# enregistre l'attribution de mŽdailles et citations pour chaque pilote
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



# Table: Decoration
# -----------------
# Liste des diverses mŽdailles et citations attribuables aux avatars/pilotes
# --------------------
# id | nom | nation_id
# --------------------
class Decoration
  include DataMapper::Resource
  
  property :id,       Serial
  property :nom,      Text, :required => true
  #property :image,    Binary
  
  belongs_to :nation
  
  has n, :rewards

end



# Table: Grade
# -----------------
# Liste des divers grades attribuables aux avatars/pilotes
# --------------------
# id | nom | nation_id
# --------------------
class Grade
  include DataMapper::Resource
  
  property :id,       Serial
  property :nom,      Text, :required => true
  #property :image,    Binary
  
  belongs_to :nation
  
  has n, :promotions

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


# Table: StatutFinMission
# -------------------
# Etat du pilote renseignŽ en fin de mission; e.g. EjectŽ
# --------------
# id | statut |
# --------------
class StatutFinMission
  include DataMapper::Resource
  
  property :id,     Serial
  property :statut, Text, :required => true
  
end



# Table: Revendication
# -------------------
# Type de revendication renseignŽe dans le formulaire mission, e.g. Attaque au sol
# ----------------
# id | descriptif |
# ----------------
class Revendication 
  include DataMapper::Resource
  
  property :id,          Serial
  property :descriptif , Text, :required => true
  
#  has n, :flight_results
  
end



# Table: Revendication
# -------------------
# Type de victoire renseigŽe dans le formulaire mission, e.g. Probable
# -----------
# id | type |
# -----------
class Victoire 
  include DataMapper::Resource
  
  property :id,          Serial
  property :type , Text, :required => true

#  has n, :flight_results
end


# Table: Nation
# -------------------
# Liste des pays associŽs aux avions, dŽcorations et grades
# -----------
# id | pays |
# -----------
class Nation 
  include DataMapper::Resource
  
  property :id,        Serial
  property :pays,      Text, :required => true
  
#  has n, :montures
#  has n, :decorations
#  has n, :grades
end



# Table: Monture
# -------------------
# Liste des Avion et provenance (pays)
# --------------------------------------
# id | modele | specialite | nation_id |
# --------------------------------------
class Monture
  include DataMapper::Resource
  
  property :id,          Serial
  property :modele,      Text, :required => true
  #property :image,       Binary
  # pour diffŽrencier chasse/attaque au sol?
  property :specialite,  Integer, :required => false
  
  belongs_to :nation, :required => false

end


# Table: Role
# -------------------
# Role tenu dans une mission, e.g. Ailier
# -----------
# id | type |
# -----------
class Role
  include DataMapper::Resource
  
  property :id,   Serial
  property :type, Text, :required=> true
  
end



# call after all models and relationships have been defined
DataMapper.finalize

# call to create tables (migration is automatic)
# auto upgarde does not destroy schema
DataMapper.auto_upgrade!

# auto migrate destroys and rebuilds schema
# DataMapper.auto_migrate!
