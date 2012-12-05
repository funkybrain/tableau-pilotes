=begin
 This file contains simple tables that store various lists
 of items necessary for populating the larger tables in db_models.rb 
=end

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
  property :img_src,  Text # file name of icon
  
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
  property :img_src,  Text # file name of icon
  property :rank,     Integer # to odrder them based on progression
  
  belongs_to :nation
  
  has n, :promotions

end



# Table: StatutFinMission
# -------------------
# Etat du pilote renseigne en fin de mission; e.g. Ejecte
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



# Table: Victoire
# -------------------
# Type de victoire renseignee dans le formulaire mission, e.g. Probable
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
  property :img_src,   Text # file name of icon
  property :slug,      Text # two letter code for nation

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
  property :img_src,     Text # file name of icon

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
  
  # has n, :flights
end

