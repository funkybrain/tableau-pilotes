# query and store data required for the tableau general
class	TabGen

	include DataMapper::Resource

	property :nbr_missions,		Integer
	property :nbr_atck_sol,		Integer
	property :nbr_vict,			Integer
	property :tps_vol_tot,		String
	property :palmares,			String

	belongs_to :grade
	belongs_to :monture
	belongs_to :role
	belongs_to :autruche, :key => true
	belongs_to :campagne, :key => true

	def self.updateTable(autrucheId, campaignId)
		# todo: call each method and update
		# the TabGen model/tab_gens table
		n_mis = nombreMissions(autrucheId, campaignId)
		n_sol = nombreAttaqueSol(autrucheId, campaignId)
		n_vic = nombreVictoires(autrucheId, campaignId)
		t_vol = tempsVolTotal(autrucheId, campaignId)
		palma = palmaresPilote(autrucheId, campaignId)
		lrole = lastRole(autrucheId, campaignId)
		dmont = derniereMonture(autrucheId, campaignId)
		gpil = gradePilote(autrucheId, campaignId)

		row = first_or_new(:autruche_id => autrucheId, :campagne_id => campaignId)

		row.attributes = {
	                       	:nbr_missions => n_mis,
													:nbr_atck_sol => n_sol,
													:nbr_vict => n_vic,
													:tps_vol_tot => t_vol,
													:palmares => palma,
													:monture_id => dmont,
													:grade_id => gpil,
													:role_id => lrole
                         }
  
    return row.save
		
	end

	def self.gradePilote(autrucheId, campaignId)
		# returns current rank of pilot on this campaign
		grade_id = Flight.byCampaign(campaignId).byAutruche(autrucheId).avatar.promotions.last.grade_id
		return Grade.get(grade_id).id
	end

	def self.nombreMissions(autrucheId, campaignId)
		# return how many mission a pilot has been 
		# on for this campaign

		# return count of flights for this autruche/campaign pair
		return Flight.byCampaign(campaignId).count(Flight.avatar.autruche_id => autrucheId)
	end

	def self.derniereMonture(autrucheId, campaignId)
		# return the last plane the pilot used
		# on the current campaign (lats mission flown)
		return Flight.byCampaign(campaignId).byAutruche(autrucheId).last.monture.id
	end

	def self.nombreVictoires(autrucheId, campaignId)
		# return how many victories the pilot
		# has in current campaign
		
		return Flight.byCampaign(campaignId).byAutruche(autrucheId).count(Flight.flight_results.revendication_id => 1) # 1: victoire aerienne (fix this, id could change in future)

	end

	def self.nombreAttaqueSol(autrucheId, campaignId)
		# return how many straffing missions
		# the pilot has completed

		return Flight.byCampaign(campaignId).byAutruche(autrucheId).count(Flight.flight_results.revendication_id => 2) # 2: attaque sol (fix, id could change)		
	end

	def self.tempsVolTotal(autrucheId, campaignId)
		# todo: return cumulative flight time of pilot
		# for current campaign
		sum_hr = Flight.byCampaign(campaignId).byAutruche(autrucheId).sum(:tps_vol_hr)
		sum_mi = Flight.byCampaign(campaignId).byAutruche(autrucheId).sum(:tps_vol_min)

		if sum_mi > 59
			add_hr = sum_mi / 60
			add_mi = sum_mi % 60
			sum_hr += add_hr
			sum_mi = add_mi
		end

		# todo: validate fields so that min never higher than 59
		return sum_hr.to_s + "h" + sum_mi.to_s

	end

	def self.lastRole(autrucheId, campaignId)
		# return role of pilot on last mission flown
		# of current campaign
		return Flight.byCampaign(campaignId).byAutruche(autrucheId).role.last.id
	end

	def self.palmaresPilote(autrucheId, campaignId)
		# todo: return list of all medals and citations
		# for pilot on current campaign
		# create a string out of all the decoratiosn id
		# eg: id1:id2:id3
		# store that string
		# upon retrieval, parse that string to get all required images

		all_rewards = Flight.byCampaign(campaignId).byAutruche(autrucheId).rewards
		palm = ""
		all_rewards.each do |r|
			palm += r.decoration_id.to_s + ":"
		end

		return palm.chop! # removes last character
	end

end

