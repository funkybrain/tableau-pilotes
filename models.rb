# setup db connection
# DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/autruche.db")
# To pull db from heroku heroku db:pull postgres://localhost/project.db
DataMapper::setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/autruche.db")

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
  
  belongs_to :autruche
  
  has n, :flights
  has n, :promotions
  has n, :rewards
  
  has n, :missions,    :through => :flights
  has n, :grades,      :through => :promotions
  has n, :decorations, :through => :rewards
 
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
  property :date_hist,  DateTime,:required => false
  property :created_at,  DateTime
  
  belongs_to :campagne

  has n, :flights
  has n, :avatars, :through => :flights
 
end

class Decoration
  include DataMapper::Resource
  property :id,       Serial
  property :nom,      Text, :required => true
  #property :image,    Binary
  
  has 1, :nation
  
  has n, :rewards
  has n, :avatars, :through => :rewards
end

class Grade
  include DataMapper::Resource
  property :id,       Serial
  property :nom,      Text, :required => true
  #property :image,    Binary
  
  has 1, :nation
  
  has n, :promotions
  has n, :avatars, :through =>:promotions
end

###################
### JOIN TABLES ###
###################

# Flight model - defines the join between avatars and missions
# use it to store meta-data about when an avatar went on a mission
class Flight
  include DataMapper::Resource
  
  property :created_at,  DateTime
  property :updated_at,  DateTime
  
  belongs_to :avatar,  :key => true
  belongs_to :mission, :key => true
  has 1, :monture
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

# Reward model - defines the join between avatars and decorations
# use it to store meta-data about when an avatar gets a decoration
class Reward
  include DataMapper::Resource
  
  property :date_decoration, DateTime
  property :created_at,  DateTime
  property :updated_at,  DateTime
  
  belongs_to :avatar,     :key => true
  belongs_to :decoration, :key => true
  
  has 1, :mission
end

#####################
### HELPER MODELS ###
#####################

class StatutFinMission
  include DataMapper::Resource
  property :id,     Serial
  property :statut, Text, :required => true  
end

class Revendication
  include DataMapper::Resource
  property :id,          Serial
  property :descriptif , Text, :required => true
end

class Monture
  include DataMapper::Resource
  property :id,          Serial
  property :modele,      Text, :required => true
  property :image,       Binary
  property :specialite,  Integer
  
  has 1, :nation
  belongs_to :flight
end

class Nation
  include DataMapper::Resource
  property :id,        Serial
  property :pays,      Text, :required => true
  
  belongs_to :monture
  belongs_to :decoration
  belongs_to :grade
end






# call after all models and relationships have been defined
DataMapper.finalize
# call to create tables (migration is automatic)
DataMapper.auto_upgrade!

# you will need to do auto_upgrade (without !) if you want to change or drop exisiting columns.
# this WILL delete the database though