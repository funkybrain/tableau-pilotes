# encoding: UTF-8

# seeding for testing
class DbSeed
  
  # seed Nation
    @@fr = Nation.first_or_create(:pays => 'France', :slug => 'fr')
    @@ge = Nation.first_or_create(:pays => 'Allemagne', :slug => 'ge')
    @@us = Nation.first_or_create(:pays => 'Etats Unis', :slug => 'us')
    @@it = Nation.first_or_create(:pays => 'Italie', :slug => 'it')
    @@ur = Nation.first_or_create(:pays => 'URSS', :slug => 'ussr')
    @@gb = Nation.first_or_create(:pays => 'Grande Bretagne', :slug => 'gb')

  def self.Main
    
    Decoration
    Autruche
    Campagne
    Mission

  end

  def self.Decoration
    # seed decorations
    deco1 = Decoration.first_or_create(:nom => 'Citation', :nation_id => @@fr.id)
    deco2 = Decoration.first_or_create(:nom => 'Ordre du merite', :nation_id => @@fr.id)
    deco4 = Decoration.first_or_create(:nom => 'Croix de Guerre', :nation_id => @@fr.id)
  
  end  
    
  def self.Autruche
    # seed autuches and avatars  
    easy = Autruche.first_or_create(:nom=>'Tabarly', :prenom=> 'Emmanuel', :callsign=>'Easy')
    warpig = Autruche.first_or_create(:nom=>'Rio', :prenom=> 'Sebastien', :callsign=>'Warpig')
    gnou = Autruche.first_or_create(:nom=>'Hauser', :prenom=> 'Jerome', :callsign=>'Gnou')
    deuxpattes = Autruche.first_or_create(:nom=>'Ruel', :prenom=> 'Gregory', :callsign=>'2Pattes')
    
    avatar1 = Avatar.first_or_create(:nom=>'Georges', :prenom=> 'Merritt', :autruche_id => 1, :nation_id => @@us.id)
    avatar2 = Avatar.first_or_create(:nom=>'Jefferson', :prenom=> 'Wood', :autruche_id => 2, :nation_id => @@us.id)
    avatar3 = Avatar.first_or_create(:nom=>'Henry', :prenom=> 'Lederer', :autruche_id => 3, :nation_id => @@us.id)
    avatar4 = Avatar.first_or_create(:nom=>'Wayne', :prenom=> 'Lacroix', :autruche_id => 4, :nation_id => @@us.id)
    

    grade = Grade.first(:rank => 1, :nation_id => @@us.id)
    start_rank1 = Promotion.first_or_create(:avatar_id => avatar1.id, :grade_id => grade.id)
    start_rank2 = Promotion.first_or_create(:avatar_id => avatar2.id, :grade_id => grade.id)
    start_rank3 = Promotion.first_or_create(:avatar_id => avatar3.id, :grade_id => grade.id)
    start_rank4 = Promotion.first_or_create(:avatar_id => avatar4.id, :grade_id => grade.id)

  end     

  def self.Campagne
    # seed campagne
    @camp1 = Campagne.first_or_create(:nom => 'Campagne Rouge',
     :descriptif => 'Sus aux Bolcheviks', :nation_id => @@ur.id)
    
    @camp2 = Campagne.first_or_create(:nom => '361FG Normandie',
     :descriptif => 'En normandie, les vaches aussi aiment les Spits!',
      :isactive => true, :nation_id => @@us.id)
    
  end

  def self.Mission
    # seed mission
    miss1 = Mission.first_or_create(:numero => 1,
                                   :nom => 'Terreur a Novorosik',
                                   :briefing => 'Longue vie aux Bolcheviks',
                                   :debriefing => 'Le peuple sest exprime',
                                   :campagne_id => @camp1.id
                                  )
    
    miss2 = Mission.first_or_create(:numero => 2,
                                   :nom => 'Prise de Moscou',
                                   :briefing => 'Le Reich reichera',
                                   :debriefing => 'Rouge vaut mieux que Bleu',
                                   :campagne_id => @camp1.id
                                  )

    miss3 = Mission.first_or_create(:numero => 1,
                                   :nom => 'Reconnaissance sur Cherbourg',
                                   :briefing => 'Click click photo',
                                   :debriefing => 'Pellicules perdues',
                                   :campagne_id => @camp2.id
                                  )      
  end  



  def self.allHelpers
    Planes
    Roles
    Statut
    Revendication
    Victoire
    Grade
  
  end

  def self.Planes
    # seed planes
    p47d10 = Monture.first_or_create(:modele=> 'P-47-D-10', :nation_id => @@us.id)
    p47d22 = Monture.first_or_create(:modele=> 'P-47-D-22', :nation_id => @@us.id)
    p47d27 = Monture.first_or_create(:modele=> 'P-47-D-27', :nation_id => @@us.id)
    bf109 = Monture.first_or_create(:modele=> 'Bf-109-E', :nation_id => @@ge.id)
    bf110 = Monture.first_or_create(:modele=> 'Bf-110', :nation_id => @@ge.id)
    fw190 = Monture.first_or_create(:modele=> 'FW-190', :nation_id => @@ge.id)
    
  end

  def self.Roles
    # seed roles
    role1 = Role.first_or_create(:type => 'Ailier')
    role2 = Role.first_or_create(:type => 'Leader de Paire')
    role3 = Role.first_or_create(:type => 'Leader de Groupe')
    
  end

  def self.Statut
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
    
  end

  def self.Revendication
    # seed revendications
    rev1 = Revendication.first_or_create(:descriptif => "Victoire Aérienne") 
    rev2 = Revendication.first_or_create(:descriptif => "Attaque au sol") 
    rev3 = Revendication.first_or_create(:descriptif => "Attaque de navire") 
    rev4 = Revendication.first_or_create(:descriptif => "Cible secondaire") 
    
  end

  def self.Victoire
    # seed victoires
    vic1 = Victoire.first_or_create(:type => "Confirmée")
    vic2 = Victoire.first_or_create(:type => "Partagée")
    vic1 = Victoire.first_or_create(:type => "Probable")
    # vic1 = Victoire.first_or_create(:type => "Endommagée")    
    
  end

  def self.Grade
    # seed grades
    gb01 = Grade.first_or_create(:rank => 1, :nom => "Pilot Officer", :img_src => "01_po.png", :nation_id => @@gb.id)
    gb02 = Grade.first_or_create(:rank => 2, :nom => "Flight Officer", :img_src => "02_fo.png", :nation_id => @@gb.id)
    gb03 = Grade.first_or_create(:rank => 3, :nom => "Flight Lieutenant", :img_src => "03_flt.png", :nation_id => @@gb.id)
    gb04 = Grade.first_or_create(:rank => 4, :nom => "Squadron Leader", :img_src => "04_sldr.png", :nation_id => @@gb.id)
    gb05 = Grade.first_or_create(:rank => 5, :nom => "Wing Commander", :img_src => "05_wcdr.png", :nation_id => @@gb.id)
    gb06 = Grade.first_or_create(:rank => 6, :nom => "Group Captain", :img_src => "06_gcpt.png", :nation_id => @@gb.id)
    #ge
    us01 = Grade.first_or_create(:rank => 1, :nom => "Sergeant", :img_src => "01_sgt.png", :nation_id => @@us.id)
    us01 = Grade.first_or_create(:rank => 2, :nom => "2nd Lieutenant", :img_src => "01_sgt.png", :nation_id => @@us.id)
    us01 = Grade.first_or_create(:rank => 3, :nom => "1st Lieutenant", :img_src => "01_sgt.png", :nation_id => @@us.id)
    us01 = Grade.first_or_create(:rank => 4, :nom => "Captain", :img_src => "01_sgt.png", :nation_id => @@us.id)
    us01 = Grade.first_or_create(:rank => 5, :nom => "Major", :img_src => "01_sgt.png", :nation_id => @@us.id)
    us01 = Grade.first_or_create(:rank => 6, :nom => "Lieutenant Commander", :img_src => "01_sgt.png", :nation_id => @@us.id)
    us01 = Grade.first_or_create(:rank => 7, :nom => "Colonel", :img_src => "01_sgt.png", :nation_id => @@us.id)
    us01 = Grade.first_or_create(:rank => 8, :nom => "General", :img_src => "01_sgt.png", :nation_id => @@us.id)
    #ussr
    
  end
end
