# encoding: UTF-8

# seeding for testing
class DbSeed
    
    # seed Nation
    @@fr = Nation.first_or_create(:pays => 'France')
    @@gr = Nation.first_or_create(:pays => 'Allemagne')
    @@us = Nation.first_or_create(:pays => 'Etats Unis')
    @@it = Nation.first_or_create(:pays => 'Italie')
    

  def self.seedMain
    
    # seed decorations
    deco1 = Decoration.first_or_create(:nom => 'Citation', :nation_id => @@fr.id)
    deco2 = Decoration.first_or_create(:nom => 'Ordre du merite', :nation_id => @@fr.id)
    deco4 = Decoration.first_or_create(:nom => 'Croix de Guerre', :nation_id => @@fr.id)
    
       
# seed autuches  
    easy = Autruche.first_or_create(:nom=>'Tabarly', :prenom=> 'Emmanuel', :callsign=>'Easy')
    warpig = Autruche.first_or_create(:nom=>'Rio', :prenom=> 'Sebastien', :callsign=>'Warpig')
    gnou = Autruche.first_or_create(:nom=>'Hauser', :prenom=> 'Jerome', :callsign=>'Gnou')
    deuxpattes = Autruche.first_or_create(:nom=>'Ruel', :prenom=> 'Gregory', :callsign=>'2Pattes')
    
    avatar1 = Avatar.first_or_create(:nom=>'Georges', :prenom=> 'Merritt', :autruche_id => 1)
     
    avatar2 = Avatar.first_or_create(:nom=>'Jefferson', :prenom=> 'Wood', :autruche_id => 3)

    
    avatar31 = Avatar.first_or_create(:nom=>'Henry', :prenom=> 'Lederer', :autruche_id => 2)
    avatar32 = Avatar.first_or_create(:nom=>'Charles', :prenom=> 'Bergman', :autruche_id => 2, :statut => false)

    
    avatar4 = Avatar.first_or_create(:nom=>'Wayne', :prenom=> 'Lacroix', :autruche_id => 4)
 

    # seed campagne
    camp1 = Campagne.first_or_create(:nom => 'Campagne Rouge', :descriptif => 'Sus aux Bolcheviks')
    camp2 = Campagne.first_or_create(:nom => '361FG Normandie', :descriptif => 'En normandie, les vaches aussi aimes les Spits!', :isactive => false)
    
    # seed mission
    miss1 = Mission.first_or_create(:numero => 1,
                                   :nom => 'Terreur a Novorosik',
                                   :briefing => 'Longue vie aux Bolcheviks',
                                   :debriefing => 'Le peuple sest exprime',
                                   :campagne_id => camp1.id
                                  )
    
    miss2 = Mission.first_or_create(:numero => 2,
                                   :nom => 'Prise de Moscou',
                                   :briefing => 'Le Reich reichera',
                                   :debriefing => 'Rouge vaut mieux que Bleu',
                                   :campagne_id => camp1.id
                                  )

    miss3 = Mission.first_or_create(:numero => 1,
                                   :nom => 'Reconnaissance sur Cherbourg',
                                   :briefing => 'Click click photo',
                                   :debriefing => 'Pellicules perdues',
                                   :campagne_id => camp2.id
                                  )

  end



  def self.seedHelpers
    # seed planes
    p47d10 = Monture.first_or_create(:modele=> 'P-47-D-10', :nation_id => @@us.id)
    @@it = Monture.first_or_create(:modele=> 'P-47-D-22', :nation_id => @@us.id)
    @@it = Monture.first_or_create(:modele=> 'P-47-D-27', :nation_id => @@us.id)
    @@it = Monture.first_or_create(:modele=> 'Bf-109-E', :nation_id => @@gr.id)
    bf110 = Monture.first_or_create(:modele=> 'Bf-110', :nation_id => @@gr.id)
    fw190 = Monture.first_or_create(:modele=> 'FW-190', :nation_id => @@gr.id)

    # seed roles
    role1 = Role.first_or_create(:type => 'Ailier')
    role2 = Role.first_or_create(:type => 'Leader de Paire')
    role3 = Role.first_or_create(:type => 'Leader de Groupe')


    # seed statut fin mission
    statut1 = StatutFinMission.first_or_create(:statut=> 'RTB')
    statut2 = StatutFinMission.first_or_create(:statut=> 'Mort')
    statut3 = StatutFinMission.first_or_create(:statut=> 'Ejecté ou Posé (territoire ennemi)')
    statut4 = StatutFinMission.first_or_create(:statut=> 'Ejecté (territoire ami)')
    statut5 = StatutFinMission.first_or_create(:statut=> 'Rentré à la base (endommagé)')
    statut6 = StatutFinMission.first_or_create(:statut=> 'Posé sur ue base (intact)')
    statut7 = StatutFinMission.first_or_create(:statut=> 'Posé sur ue base (endommagé)')
    statut8 = StatutFinMission.first_or_create(:statut=> 'Posé en territoire ami (intact)')
    statut9 = StatutFinMission.first_or_create(:statut=> 'Posé en territoire ami (endommagé)')
    
    # seed revendications
    rev1 = Revendication.first_or_create(:descriptif => "Victoire Aérienne") 
    rev2 = Revendication.first_or_create(:descriptif => "Attaque au sol") 
    rev3 = Revendication.first_or_create(:descriptif => "Attaque de navire") 
    rev4 = Revendication.first_or_create(:descriptif => "Cible secondaire") 

    # seed victoires
    vic1 = Victoire.first_or_create(:type => "Confirmée")
    vic2 = Victoire.first_or_create(:type => "Partagée")
    vic1 = Victoire.first_or_create(:type => "Probable")
    vic1 = Victoire.first_or_create(:type => "Endommagée")    
  
  end

end
