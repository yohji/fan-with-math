#
#	Copyright (c) 2016 Marco Merli <yohji@marcomerli.net>
#   
#	This program is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; either version 2 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program; if not, write to the Free Software Foundation,
#	Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

class Game
	
	module Type
		
		ARITHMETIC = 1
		LOGICAL = 2
	end
	
	module Level
		
		STUPID = 1
		NORMAL = 2
		TALENT = 3
		NERD = 4
		GENIUS = 5
	end
	
	ARITHMETIC_OPR = ['+', '-', '*', '/']
	LOGICAL_OPR = ['&', '|', '^']
	
	attr_accessor :rallies, :results
	
	def initialize(type, level)
		
		@rnd = Random.new
		
		@rallies = Array.new
		@results = Array.new
		@index = -1
		
		(10 + (level * Math.log2(level)).to_i).times do
			@rallies << expression(type, level)
		end
	end
	
	def current
		
		return @rallies[(@index += 1)]
	end
	
	def store(value)
		
		@results.push(value)
	end
	
	def expression(type, level)
		
		case type
		when Type::ARITHMETIC
		
			ra = "10#{'0' * (1 << (level - 2))}".to_i
			rb = "10#{'0' * (1 << (level - 3))}".to_i
			opr = ARITHMETIC_OPR[@rnd.rand(4)]
		
			a = @rnd.rand(ra)
			if opr == '/'
				until a % (b = @rnd.rand(rb) + 1) == 0 do end
			else
				b = @rnd.rand(rb)
			end
		
		when Type::LOGICAL
			
			a = @rnd.rand(2)
			opr = LOGICAL_OPR[@rnd.rand(3)]
			b = @rnd.rand(2)
		end
		
		return "#{a} #{opr} #{b}"
	end
end
