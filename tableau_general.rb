# query and store data required for the tableau general
class	TabGen

	include DataMapper::Resource

	property :id,				Serial
	property :nbr_missions,		Integer
	property :nbr_atck_sol,		Integer
	property :nbr_vict,			Integer
	property :tps_vol_tot,		Integer
	property :palmares,			String

	belongs_to :grade
	belongs_to :monture
	belongs_to :role
	belongs_to :autruche


	def self.gradePilote(autrucheId, campaignId)
		# returns current rank of pilot on this campaign
	end

	def self.nombreMissions(autrucheId, campaignId)
		# todo: return how many mission a pilot has been 
		# on for this campaign

		# return count of flights for this autruche/campaign pair
		return Flight.byCampaign(campaignId).count(Flight.avatar.autruche_id => autrucheId)
	end

	def self.derniereMonture(autrucheId, campaignId)
		# todo: return the last plane the pilot used
		# on the current campaign (lats mission flown)
		


	end

	def self.nombreVictoires(autrucheId, campaignId)
		# todo: return how many victories the pilot
		# has in current campaign
		
		return Flight.byCampaign(campaignId).byAutruche(autrucheId).count(Flight.flight_results.victoire_id => 1)
		# 1: victoire aerienne ... need to make this more robust in case id changes

	end

	def self.nombreAttaqueSol(autrucheId, campaignId)
		# todo: return how many straffing missions
		# the pilot has completed

		return Flight.byCampaign(campaignId).byAutruche(autrucheId).count(Flight.flight_results.victoire_id => 2)
		# 2: attaque sol ... need to make this more robust in case id changes		
	end

	def self.tempsVolTotal(autrucheId, campaignId)
		# todo: return cumulative flight time of pilot
		# for current campaign
		
	end

	def self.lastRole(autrucheId, campaignId)
		# todo: return role of pilot on last mission flown
		# of current campaign
		
	end

	def self.palmaresPilote(autrucheId, campaignId)
		# todo: return list of all medals and citations
		# for pilot on current campaign
		# create a string out of all the decoratiosn id
		# eg: id1:id2:id3
		# store that string
		# upon retrieval, parse that string to get all required images
	end
end

