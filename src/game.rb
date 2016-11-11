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
	
	attr_accessor :rallies, :results
	
	def initialize(type, level)
		
		@type = type
		@level = level
		exp = Expression.new(type, level)
		
		@rallies = Array.new
		@results = Array.new
		@index = -1
		
		(10 + (level * Math.log2(level)).to_i).times do
			@rallies << exp.build
		end
	end
	
	def current
		
		return @rallies[(@index += 1)]
	end
	
	def store(value)
		
		if @type == Type::LOGICAL
			value = "true" if value == "1"
			value = "false" if value == "0"
		end
		
		@results.push(value)
	end
end

class Expression
		
	ARITHMETIC_OPR = ['+', '-', '*', '/']
	LOGICAL_OPR = ['&', '|', '^']
		
	def initialize(type, level)
		
		@type = type
		@level = level
			
		@range_a = "10#{'0' * (1 << (@level - 2))}".to_i
		@range_b = "10#{'0' * (1 << (@level - 3))}".to_i
			
		@rnd = Random.new
	end
	
	def build
		
		case @type
		when Game::Type::ARITHMETIC
			deep = @rnd.rand(@level)
		
		when Game::Type::LOGICAL
			deep = @rnd.rand(1 << ((@level - 1) + Math.log2(@level)))
		end
		
		exp = _core
		deep.times do
			exp = _extend exp
		end
			
		return exp
	end
	
	private
	def _core
		
		case @type
		when Game::Type::ARITHMETIC
			
			a = @rnd.rand(@range_a)
			opr = ARITHMETIC_OPR[@rnd.rand(4)]
		
			if opr == '/'
				until a % (b = @rnd.rand(@range_b) + 1) == 0 do end
			else
				b = @rnd.rand(@range_b)
			end
			
			return "#{a} #{opr} #{b}"
		
		when Game::Type::LOGICAL
			
			na = @rnd.rand(2) == 1 ? '!' : ''
			a = @rnd.rand(2) == 1 ? "true" : "false"
		
			opr = LOGICAL_OPR[@rnd.rand(3)]
		
			nb = @rnd.rand(2) == 1 ? '!' : ''
			b = @rnd.rand(2) == 1 ? "true" : "false"
			
			return "#{na}#{a} #{opr} #{nb}#{b}"
		end
	end
	
	private
	def _extend exp
		
		case @type
		when Game::Type::ARITHMETIC
			
			opr = ARITHMETIC_OPR[@rnd.rand(4)]
		
			if opr == '/'
				until eval(exp) % (b = @rnd.rand(@range_b) + 1) == 0 do end
			else
				b = @rnd.rand(@range_b)
			end
			
			return "(#{exp}) #{opr} #{b}"
		
		when Game::Type::LOGICAL
			
			opr = LOGICAL_OPR[@rnd.rand(3)]
			nb = @rnd.rand(2) == 1 ? '!' : ''
			b = @rnd.rand(2) == 1 ? "true" : "false"
			
			return "(#{exp}) #{opr} #{nb}#{b}"
		end
	end
end
