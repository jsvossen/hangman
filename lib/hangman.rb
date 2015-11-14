require "./lib/stickman.rb"
require 'yaml'

class Hangman

	attr_reader :dictionary, :word, :stickman, :correct, :wrong
	
	def initialize
		@dictionary = []
		File.readlines("5desk.txt").each do |word|
			word = word.chomp.downcase
			@dictionary << word if word.length > 4 && word.length < 13
		end

		@word = @dictionary.sample
		@stickman = StickMan.new
		@correct = Array.new(@word.size, "_")
		@wrong = []
		play
	end

	def reset_game
		@word = @dictionary.sample
		@stickman = StickMan.new
		@correct = Array.new(@word.size, "_")
		@wrong = []
	end

	def draw_gallows
		puts " |----|"
		puts " #{@stickman.head.draw}    |"
		puts "#{@stickman.left_arm.draw+@stickman.torso.draw+@stickman.right_arm.draw}   |"
		puts "#{@stickman.left_leg.draw+ " " +@stickman.right_leg.draw}   |"
		puts "      |"
		puts "-------"
	end

	#are all stickman parts flagged?
	def hanged?
		@stickman.parts.all? { |p| p.flag == true }
	end

	#is the stickman fully flagged, or the word guessed?
	def game_over
		hanged? || @correct.none? { |c| c == "_"}
	end

	#check if letter has been guessed already
	def good_guess?(guess)
		!@correct.include?(guess) && !@wrong.include?(guess)
	end

	#accept a single letter as valid input
	def valid_input?(guess)
		guess.match("^[a-z]$")
	end

	def play

		until game_over do
			draw_gallows
			puts correct.join

			guess = gets.chomp.downcase

			until valid_input?(guess) && good_guess?(guess) do
				if guess.include?("save")
					filename = guess.split[1]
					if filename != "" && filename != " " && filename != nil
						save_game(self,filename)
					else
						puts "Save name is missing. Type SAVE followed by a file name."
					end
					guess = gets.chomp.downcase
				else
					puts "Enter a letter to guess" if !valid_input?(guess)
					puts "You already guessed that" if !good_guess?(guess)
					guess = gets.chomp.downcase
				end
			end

			if @word.include?(guess)
				position = @word.split(//).find_indicies(guess)
				position.each { |p| correct[p] = guess }
			else
				@wrong << guess
				@stickman.parts[wrong.size-1].flag = true
			end
		end

		draw_gallows
		puts @word
		puts hanged? ? "You lose!" : "You win!"
		play_again_check
	end

	#option to play again
	def play_again_check
		puts "Would you like to play again?"
		input = gets.chomp.downcase
		if input != "no" && input != "n"
			if input == "yes" || input == "y"
				reset_game
				play
			else
				puts "Respond yes or no"
				play_again_check
			end
		end
	end

end

def save_game(game,filename)
	yaml = YAML::dump(game)
	Dir.mkdir("saves") unless Dir.exists? "saves"
	file_path = "saves/#{filename}.yml"
	File.open(file_path,"w") do |file|
		file.puts yaml
	end
	puts "#{filename} saved!"
end

def load_game(filename)
	file_path = "saves/#{filename}.yml"
	if File.exists?(file_path)
		save = YAML.load_file(file_path)
	else
		puts "Saved game '#{filename}' does not exist"
	end
end

class Array
	#helper function to find multiple indicies incase array containing duplicates
	def find_indicies(a)
		indicies = []
		self.each_with_index do |x,i|
			indicies << i if x == a
		end
		indicies
	end
end

#Prompt save or load at start
puts "Start a NEW game or LOAD a saved game?"
start = gets.chomp.downcase
file = start.split[1]
until start == "new" || load_game(file) do
	puts "Type NEW for a new game or LOAD plus the save name to load a game"
	start = gets.chomp.downcase
end
if start == "new"
	Hangman.new
else
	load_game(file).play
end
