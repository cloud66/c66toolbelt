require "c66/utils/version"
require "c66/commands/c66_toolbelt"

module C66
	def self.thorStart
		Commands::C66Toolbelt.start	
	end
end