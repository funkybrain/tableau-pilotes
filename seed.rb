
# seeding for testing
class DbSeed
  def self.seed


# seed Nation
  
    fr = Nation.first_or_create(:pays => 'France')
    gr = Nation.first_or_create(:pays => 'Allemagne')
    us = Nation.first_or_create(:pays => 'Etats Unis')
    it = Nation.first_or_create(:pays => 'Italie')
    
 # seed decorations
    
    deco1 = Decoration.first_or_create(:nom => 'Citation', :nation_id => fr.id)
    deco2 = Decoration.first_or_create(:nom => 'Ordre du merite', :nation_id => fr.id)
    deco4 = Decoration.first_or_create(:nom => 'Medaille en or', :nation_id => fr.id)
    
       
# seed autuches  
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
    
# seed planes

    t = Nation.first(:pays => 'Etats Unis')
    
    p47d10 = Monture.first_or_create(:modele=> 'P-47-D-10', :nation_id => t.id)
    p47d22 = Monture.first_or_create(:modele=> 'P-47-D-22', :nation_id => t.id)
    p47d27 = Monture.first_or_create(:modele=> 'P-47-D-27', :nation_id => t.id)

    t.save
    
# seed statut fin mission

    statut1 = Statutfinmission.first_or_create(:statut=> 'Pose sur une base (intact)')
    statut2 = Statutfinmission.first_or_create(:statut=> 'Pose sur une base (endommage)')
    statut3 = Statutfinmission.first_or_create(:statut=> 'Pose en territoire ami (intact)')
    statut4 = Statutfinmission.first_or_create(:statut=> 'Pose en territoire ami (endommage)')
    statut5 = Statutfinmission.first_or_create(:statut=> 'Pose en territoire enemi (campagne)')
    statut6 = Statutfinmission.first_or_create(:statut=> 'Ejecte (territoire ennemi)')
    statut7 = Statutfinmission.first_or_create(:statut=> 'Ejecte (territoire ami)')
    statut8 = Statutfinmission.first_or_create(:statut=> 'Mort')

# seed roles

    role1=Role.first_or_create(:type => 'Ailier')
    role2=Role.first_or_create(:type => 'Leader de Paire')
    role3=Role.first_or_create(:type => 'Leader de Groupe')


# seed mission
    camp = Campagne.first(:nom => 'Campagne Rouge')
    miss = Mission.first_or_create(:numero => 5,
                                  :nom => 'La Belle Rouge',
                                  :briefing => 'Longue vie aux Bolcheviks',
                                  :debriefing => 'Ah ben en fait ca cest plutot mal passe',
                                  :campagne_id => camp.id
                                  )
    puts miss.inspect   
    camp.save

# seed revendications
    rev1 = Revendication.first_or_create(:descriptif => "Victoire Aerienne") 
    rev2 = Revendication.first_or_create(:descriptif => "Attaque au sol") 
    rev3 = Revendication.first_or_create(:descriptif => "Attaque de navire") 
    rev4 = Revendication.first_or_create(:descriptif => "Straffing secondaire") 

# seed victoires
    vic1 = Victoire.first_or_create(:type => "Confirmee")
    vic2 = Victoire.first_or_create(:type => "Partagee")
    vic1 = Victoire.first_or_create(:type => "Probable")
    vic1 = Victoire.first_or_create(:type => "Endommagee")
    
  end
end
