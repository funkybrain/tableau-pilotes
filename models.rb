# setup db connection
# DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/autruche.db")
# To pull db from heroku heroku db:pull postgres://localhost/project.db
DataMapper::setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/autruche.db")

# exception handling
DataMapper::Model.raise_on_save_failure = true

# define Autruche model - liste des pilotes
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

# define Avatar model - liste des avatars de campagne
class Avatar 
  include DataMapper::Resource
  
  property :id,         Serial    #auto-increment integer key
  property :nom,        String,  :required => true
  property :prenom,     String,  :required => true
  property :statut,     Boolean, :required => true, :default => true
  property :created_at,  DateTime
  
  belongs_to :autruche #defaults to :required=>true
  
  has n, :flights
  has n, :promotions

  
  has n, :missions,    :through => :flights
  has n, :grades,      :through => :promotions
 
end

# Campagne model - liste des campagnes
class Campagne
  include DataMapper::Resource
  
  property :id,         Serial    #auto-increment integer key
  property :nom,        Text,    :required => true
  property :descriptif, Text,    :required => false, :default => "Pas de descriptif"
  property :created_at, DateTime

  has n, :missions
  
end

# Mission model - liste des missions
class Mission
  include DataMapper::Resource
  
  property :id,         Serial    #auto-increment integer key
  property :numero,     Integer, :required => true
  property :nom,        String,  :required => true
  property :briefing,   Text,    :required => false, :default => "Pas de briefing"
  property :debriefing, Text,    :required => false, :default => "Pas de debriefing"
  #property :date_hist,  DateTime,:required => false
  property :created_at,  DateTime
  
  belongs_to :campagne

  has n, :flights
  has n, :avatars, :through => :flights
 
end

# Table: Decoration
# Liste des diverses mŽdailles et citations attribuables aux avatars/pilotes
# ####################
# id | nom | nation_id
# ####################

class Decoration
  include DataMapper::Resource
  
  property :id,       Serial
  property :nom,      Text, :required => true
  #property :image,    Binary
  
  belongs_to :nation
  
  has n, :rewards
#  has n, :avatars, :through => :rewards
  
end

# Table: Reward
# enregistre l'attribution de mŽdailles et citations pour chaque pilote
# #################################################
# id | id_flight | id_decoration
# #################################################

class Reward
  include DataMapper::Resource
  
  property :id,          Serial
  property :created_at,  DateTime
  property :updated_at,  DateTime
  
  belongs_to :flight
  belongs_to :decoration
  
  def self.byFlight(id)
    all(Reward.flight.id => id)
  end

end


class Grade
  include DataMapper::Resource
  property :id,       Serial
  property :nom,      Text, :required => true
  #property :image,    Binary
  
  belongs_to :nation
  
  has n, :promotions
  has n, :avatars, :through =>:promotions
  
end

# Table: Flight
# use it to store meta-data about when an avatar went on a mission
# ##########################################################################
# id | temps_vol | id_avatar | id_mission | id_role | id_statut | id_monture
# ##########################################################################

class Flight
  
  include DataMapper::Resource
  
  # define properies and keys
  property :id,          Serial
  property :temps_vol,   Time, :required => false, :default => "00:00"
  property :created_at,  DateTime
  property :updated_at,  DateTime
  
  belongs_to :avatar,  :key => true
  belongs_to :mission, :key => true
  
  belongs_to :role
  belongs_to :statutfinmission
  belongs_to :monture
  
  has n, :flight_results
  has n, :rewards
  
  # define commonly used scopes as methods to call them from anywhere
#  def self.avatar(id)
#    all(:avatar_id => id)
#  end
  # call it with Flight.avatar(id)
  # remember that you ca chain these methods for more complex queries
  
  def self.byAutruche(id)
    #autruche = {:avatar_id => {:autruche_id => id}}
    #autruche = {Flight.avatar.autruche.id => id}
    #puts autruche
    #autruche = {:avatar_id => 72}
    all(Flight.avatar.autruche.id => id)
  end
  
end

# FlightResult - stores the revendication/victoire pair submitted in formulaire pilote
# for each Flight (i.e. for each avatar/mission pair)

class FlightResult
  
  include DataMapper::Resource
  
  property :id,           Serial
  property :commentaire,  Text, :required => false
  property :created_at,   DateTime
  
  belongs_to :revendication
  belongs_to :victoire
  belongs_to :flight
  
end

# Promotion model - defines the join between avatars and grades
# use it to store meta-data about when an avatar gets a promotion
class Promotion
  include DataMapper::Resource
  
  property :date_promotion, DateTime
  property :created_at,  DateTime
  property :updated_at,  DateTime
  
  belongs_to :avatar, :key => true
  belongs_to :grade,  :key => true
  
  #has 1, :mission
end


#####################
### HELPER MODELS ###
#####################

# Etat du pilote renseignŽ en fin de mission; e.g. EjectŽ
class Statutfinmission
  include DataMapper::Resource
  property :id,     Serial
  property :statut, Text, :required => true
  
  has n, :flights
  
end

# Type de revendication renseignŽe dans le formulaire mission, e.g. Attaque au sol
class Revendication
  
  include DataMapper::Resource
  
  property :id,          Serial
  property :descriptif , Text, :required => true
  
  has n, :flight_results
  
end

# Type de victoire renseigŽe dans le formulaire mission, e.g. Probable
class Victoire
  
  include DataMapper::Resource
  
  property :id,          Serial
  property :type , Text, :required => true

  has n, :flight_results
  
end

# Liste des pays associŽs aux avions, dŽcorations et grades
class Nation
  
  include DataMapper::Resource
  
  property :id,        Serial
  property :pays,      Text, :required => true
  
  has n, :montures
  has n, :decorations
  has n, :grades
  
end

# Liste des Avion et provenance (pays)
class Monture
  
  include DataMapper::Resource
  
  property :id,          Serial
  property :modele,      Text, :required => true
  #property :image,       Binary
  property :specialite,  Integer, :required => false
  
  belongs_to :nation, :required => false

  has n, :flights
  
end

# Role tenu dans une mission, e.g. Ailier
class Role
  include DataMapper::Resource
  
  property :id,   Serial
  property :type, Text, :required=> true
  
  has n, :flights
  
end



# call after all models and relationships have been defined
DataMapper.finalize

# call to create tables (migration is automatic)
# auto upgarde does not destroy schema
DataMapper.auto_upgrade!

# auto migrate destroys and rebuilds schema
# DataMapper.auto_migrate!
