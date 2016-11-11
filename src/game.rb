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
		
		@results.push(value)
	end
end

class Expression
		
	ARITHMETIC_OPR = ['+', '-', '*', '/']
	LOGICAL_OPR = ['&', '|', '^']
		
	def initialize(type, level)
		
		@type = type
		@level = level
			
		@range_a = "10#{'0' * (1 << (level - 2))}".to_i
		@range_b = "10#{'0' * (1 << (level - 3))}".to_i
			
		@rnd = Random.new
	end
	
	def build
		
		case @type
		when Game::Type::ARITHMETIC
			return _build_arithmetic
			
		
		when Game::Type::LOGICAL
			return _build_logical
			
		end
	end
	
	private
	def _build_arithmetic
		
		a = @rnd.rand(@range_a)
		opr = ARITHMETIC_OPR[@rnd.rand(4)]
		
		if opr == '/'
			until a % (b = @rnd.rand(@range_b) + 1) == 0 do end
		else
			b = @rnd.rand(@range_b)
		end
			
		return "#{a} #{opr} #{b}"
	end
	
	private
	def _build_logical
		
		na = @rnd.rand(2) == 1 ? '!' : ''
		a = @rnd.rand(2)
		
		opr = LOGICAL_OPR[@rnd.rand(3)]
		
		nb = @rnd.rand(2) == 1 ? '!' : ''
		b = @rnd.rand(2)
			
		return "#{na}#{a} #{opr} #{nb}#{b}"
	end
end
