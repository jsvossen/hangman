class StickMan
	
	attr_reader :head, :torso, :left_arm, :right_arm, :left_leg, :right_leg, :parts
	
	def initialize
		@head = BodyPart.new("O")
		@torso = BodyPart.new("|")
		@left_arm = BodyPart.new("/")
		@right_arm = BodyPart.new("\\")
		@left_leg = BodyPart.new("/")
		@right_leg = BodyPart.new("\\")
		@parts = [ @head, @torso, @left_arm, @right_arm, @left_leg, @right_leg ]
	end
	


	class BodyPart
		attr_accessor :symbol, :flag
		def initialize(symbol)
			@flag = false
			@symbol = symbol
		end

		def draw
			@flag ? @symbol.to_s : " "
		end
	end

end