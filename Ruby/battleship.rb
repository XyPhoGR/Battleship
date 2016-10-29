module Battleship

	Default_width = 10

	Ship_none = 0
	Ship_alive = 1
	Ship_dead = 2

	View_water = 0
	View_hit = 1
	View_miss = 2

	class Board

		attr_accessor :width :height
	
		# Create the object
		def initialize(*args)
			if args.length == 1
				@width = @height = args[0]
			else
				@width = args[0]
				@height = args[1]
			end
			@board_ships = Array.new(@width) { Array.new(@height) }
			@board_view = Array.new(@width) { Array.new(@height) }
			@ships = Array.new
		end

		def checkBounds(x, y)
			return false if (x < 0 || x >= @width)
			return false if (y < 0 || y >= @height)
			true
		end

		def getView(x, y)
			return @board_view[x][y] if checkBounds(x, y)
			View_water
		end

		def getShip(x, y)
			return @board_ships[x][y] if checkBounds(x, y)
			Ship_none
		end

		def getNumShips()
			ships.length
		end

		def addShip(x, y)
			if checkBounds(x, y)
				if @board_ships[x][y] != Ship_alive
					@board_ships[x][y] = Ship_alive
					@ships.push([x, y])
					true
				end
			end
			false
		end

		def addShips(x, dx, y, dy)
			#check bounds
			(x..(x + dx - 1).each do |i|
				(y..(y + dx - 1).each do |j|
					return false unless self.checkBounds(i, j)
					return false if @board_ships[i][j] == Ship_alive
				end
			end
			#add
			(x..(x + dx - 1).each do |i|
				(y..(y + dx - 1).each do |j|
					addShip(i, j)
				end
			end
			true
		end

		def missile(x, y)
			return false if not checkBounds(x, y)
			return false if @board_view[x][y] == View_hit
			if @board_ships[x][y] == Ship_alive
				@board_view[x][y] = View_hit
				@board_ships[x][y] = Ship_dead
				@ships.delete([x, y])
				true
			else
				@board_view[x][y] = View_miss
				false
			end
		end

		def to_s
			"Board[#{@width}x#{@height}]"
		end

	end #Board class

	#command line utility methods

	def printView(board)
		#column labels
		print " "
		(0..(board.width - 1).each do |x|
			print getColumnLetter(x)
		end
		print "\n"
		#board
		(0..(board.height - 1).each do |y|
			#row label
			print getColumnLetter(y)
			(0..(board.width - 1).each do |x|
				print getViewCharacter(board, x, y)
			end
			print "\n"
		end
	end

	def getColumnLetter(index)
		chr(index)
	end

	def getColumnIndex(letter)
		letter.upcase.ord
	end

	def getRowLetter(index)
		index.to_s
	end

	def getRowIndex(letter)
		letter.to_i
	end

	def getViewCharacter(board, x, y)
		#the characters used to represent the states of the view array
		v = board.getView(x, y)
		return "x" if v == View_hit
		return "o" if v == View_miss
		"~"
	end

	def cget(prompt = "")
		print prompt
		gets
	end

	#game processing

	if __FILE__ == $0
		#run console

		puts "Starting battleship (Ruby)"

		#get input for size of board

		w = cget("Enter width (or blank for default of #{Default_width})): ").chomp.to_i
		w = Default_width if w <= 0
		puts "Width: #{w}"

		h = cget("Enter height (or blank for default of #{w})): ").chomp.to_i
		h = w if h <= 0
		puts "Height: #{h}"

		board = Board.new(10)

		#custom ship count

		c = cget("Enter number of ships (or blank for default of #{Default_width}): ").chomp.to_i
		c = Default_width if c <= 0
		puts "Number of ships: #{c}"

		#add the ships

		d = c
		while d > 0 do
			#TODO: it's 12:34 rn and i'm lazy

=begin
    while d > 0:
        x = random.randrange(w)
        y = random.randrange(h)
        axis = random.randrange(2)
        dx = random.randrange(w/2) + 1 if axis == 1 else 1
        dy = random.randrange(h/2) + 1 if axis == 0 else 1
        if board.addShips(x, dx, y, dy):
            d -= 1
        else:
            safety += 1
        if safety > 10000: #10000 failures is a pretty reasonable number of attempts imo
            print "Failed to generate " + str(c) + " ships. Sorry :("
            break
=end

		end

		#start game

		puts "#{board.getNumShips()} hits left!"
		puts "Note: when launching missiles, specify column then row. Ex: 'A 4' or 'b 7'"
		moves = 0
		while board.getNumShips() > 0 do

			#print the board (for the next move)

			puts
			printView(board)

			#get input

			while true do
				line = cget("Launch a missile! Coordinates: ").chomp()
				puts
				begin
					#parse
					line = line.split(" ", 2)
					column = getColumnIndex(line[0])
					row = getRowIndex(line[1])
					#act
					if board.missile(column, row)
						puts "It's a hit!"
					else
						puts "You missed!"
					end
					#results
					moves += 1
					if board.getNumShips() > 0
						puts "#{board.getNumShips()} hits left!"
					end
					break
				rescue
					puts "Invalid coordinates specified"
				end
			end

			if board.getNumShips() <= 0
				#end game

				puts
				puts "You win!"
				puts "It took you #{moves} moves."
			end

		end #game loop

	end #console

end #module