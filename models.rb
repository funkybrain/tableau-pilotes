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
  
  belongs_to :autruche #defaults to :required=>true
  
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
  
  belongs_to :nation
  
  has n, :rewards
  has n, :avatars, :through => :rewards
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
  has 1, :role
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
  
  has 1, :mission
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
  #property :image,       Binary
  property :specialite,  Integer
  
  belongs_to :nation
  belongs_to :flight
end

class Role
  include DataMapper::Resource
  
  property :id,   Serial
  property :type, Text, :required=> true
  
  belongs_to :flight
  
end

class Nation
  include DataMapper::Resource
  
  property :id,        Serial
  property :pays,      Text, :required => true
  
  has n, :monture
  has n, :decoration
  has n, :grade
end






# call after all models and relationships have been defined
DataMapper.finalize

# call to create tables (migration is automatic)
# auto upgarde does not destroy schema
DataMapper.auto_upgrade!

# auto migrate destroys and rebuilds schema
# DataMapper.auto_migrate!


# seeding for testing
class DbSeed
  def self.seed
    Autruche.all.destroy
    
    easy = Autruche.first_or_create(:nom=>'Tabarly', :prenom=> 'Emmanuel', :callsign=>'Easy')
    warpig = Autruche.first_or_create(:nom=>'Rio', :prenom=> 'Sebastien', :callsign=>'Warpig')
    gnou = Autruche.first_or_create(:nom=>'Hauser', :prenom=> 'Jerome', :callsign=>'Gnou')
    deuxpattes = Autruche.first_or_create(:nom=>'Ruel', :prenom=> 'Gregory', :callsign=>'2Pattes')
    
    avatar1 = Avatar.first_or_create(:nom=>'Georges', :prenom=> 'Merritt')
    easy.avatars << avatar1
    easy.save
    
    avatar2 = Avatar.first_or_create(:nom=>'Jefferson', :prenom=> 'Wood')
    gnou.avatars << avatar2
    gnou.save
    
    avatar31 = Avatar.first_or_create(:nom=>'Henry', :prenom=> 'Lederer')
    avatar32 = Avatar.first_or_create(:nom=>'Charles', :prenom=> 'Bergman')
    warpig.avatars << avatar31    
    warpig.avatars << avatar32
    warpig.save
    
    avatar4 = Avatar.first_or_create(:nom=>'Wayne', :prenom=> 'Lacroix')
    deuxpattes.avatars << avatar4
    deuxpattes.save
    
    p47d10 = Monture.first_or_create(:modele=> 'P-47-D-10')
    p47d22 = Monture.first_or_create(:modele=> 'P-47-D-22')
    p47d27 = Monture.first_or_create(:modele=> 'P-47-D-27')

    statut1 = StatutFinMission.first_or_create(:statut=> 'Rentre a la base')
    statut2 = StatutFinMission.first_or_create(:statut=> 'Mort')
    statut3 = StatutFinMission.first_or_create(:statut=> 'Ejecte (territoire ennemi) Evade')
    statut4 = StatutFinMission.first_or_create(:statut=> 'Ejecte (territoire ami)')
    statut5 = StatutFinMission.first_or_create(:statut=> 'Rentre a la base (endommage)')

    role1=Role.first_or_create(:type => 'Ailier')
    role2=Role.first_or_create(:type => 'Leader de Paire')
    role3=Role.first_or_create(:type => 'Leader de Groupe')


    
  end
end
