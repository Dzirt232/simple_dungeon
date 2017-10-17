class Dungeon
	attr_accessor :player
	$max_loot = 3
	def initialize(player_name)
		@player = Player.new(player_name)
		@rooms = []
		add_rooms
	end

	class Player
		attr_accessor :name, :location, :inventire
		def initialize(name)
			@name = name
			@inventire = []
		end
	end
	
	class Room
		attr_accessor :reference, :name, :description, :connections, :loot

		def initialize(reference, name, description, connections, loot)
			@reference = reference
			@name = name
			@description = description
			@connections = connections
			@loot = loot
		end

		def full_description
			@name + "\n-------------------------------\nYou are in " + @description
		end

		def find_loot?(thing)
			@loot.each { |name, kind|
				return true if thing == name
			}
			return false
		end

	end

	class Thing
		attr_accessor :name, :kind

		def initialize(name,kind)
			@name = name
			@kind = kind
		end

	end

	def create_loot(loot)
		loot.each { |name,kind|  
			@thing = Thing.new(name,kind)
		}
	end

	def take_loot(thing) 
		find_room_in_dungeon(@player.location).loot.each {|name,kind|
			if thing == name
			@player.inventire.push({name => kind})
			find_room_in_dungeon(@player.location).loot.delete(name)
			end
		}
	end

	def add_room(reference, name, description, connections, loot)
		loot = create_loot(loot)
		@room = Room.new(reference, name, description, connections, loot)
		@rooms << @room
	end

	def start(location)
		@player.location = location
		show_current_description
		@player.inventire = []
	end
	
	def show_current_description
		puts find_room_in_dungeon(@player.location).full_description
	end
	
	def find_room_in_dungeon(reference)
		@rooms.detect { |room| room.reference == reference }
	end

	def find_room_in_direction(direction)
		find_room_in_dungeon(@player.location).connections[direction]
	end

	def go(direction)
		puts "You go " + direction.to_s
		if !find_room_in_direction(direction).nil?
			@player.location = find_room_in_direction(direction)
			show_current_description
		else
		puts "Here is only big, unreachable wall..."
		show_current_description
		end
	end

	def add_rooms
		self.add_room(:largecave, "Large cave","a large cavernous cave",{:west => :smallcave, :south => :armor_room, :north => :biblioteca},
		{"Bottle of water" => :drink, "Small stick" => :weapon})
		self.add_room(:smallcave, "Small cave","a small, claustrophobic cave",{:east => :largecave},[])
		self.add_room(:biblioteca, "Biblioteca","a small room with many book shelfs...",{:south => :largecave},[])
		self.add_room(:armor_room, "Armor room","a midlle room with many different weapon",{:north => :largecave},{"Iron sword" => :weapon})
	end

	def look_for_loot
		if find_room_in_dungeon(@player.location).loot.empty?
		 	puts "Here you don't found anything useful..."
		else
			puts "Here is: "
			find_room_in_dungeon(@player.location).loot.each {|name, kind|
				puts name
			} 
			puts "........"
		end
	end

	def inventire_max?
		@player.inventire.length >= $max_loot
	end

	def inventire_take(thing)
		if find_room_in_dungeon(@player.location).find_loot?(thing)
			take_loot(thing)
			puts "You take "+thing+"."
		else
			puts "Here is not this loot..."
		end	
	end

	def show_inventire
		puts "You open your bag and see:"
		@player.inventire.each {|thing|
			puts thing.keys
		}
	end
end


puts "Enter your name: "
my_dungeon = Dungeon.new(gets.chomp)
start_room = rand(4)
case start_room
	when 0 then start_room = :largecave
	when 1 then start_room = :smallcave
	when 2 then start_room = :armor_room
	when 3 then start_room = :biblioteca
	else start_room = :largecave
end

my_dungeon.start(start_room)

loop do
	puts
	puts "What do you want to do?"
	vvod = gets.chomp.downcase
	break if vvod == "exit"
	case vvod
	when "go" 
		puts "Where do you want go?"
		napravl = gets.chomp.downcase
		my_dungeon.go(napravl.to_sym)
	when "look"
		puts "You see the place..."
		my_dungeon.look_for_loot
	when "loot"
		if my_dungeon.inventire_max?
			puts "Your inventire is full!"
		else
			puts "What do you want take?"
			take = gets.chomp.downcase
			my_dungeon.inventire_take(take.capitalize)
		end
	when "inventire"
		my_dungeon.show_inventire
	else puts "What? You are dibil?"	
	end
end