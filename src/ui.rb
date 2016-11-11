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

require 'curses'
require_relative 'game'

class UserInterface
	
	ENTER_KEY = 13
	ESC_KEY = 27
	BACK_KEY = 127
	
	module State
		
		HOME = 1
		LEVEL = 2
		GAME = 3
		RESULT = 3
	end
		
	def initialize
		
		Curses.init_screen
		Curses.start_color
		Curses.nonl
		Curses.init_pair(1, Curses::COLOR_WHITE, Curses::COLOR_BLACK)
		Curses.init_pair(2, Curses::COLOR_BLACK, Curses::COLOR_GREEN)
		Curses.init_pair(3, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
		Curses.init_pair(4, Curses::COLOR_RED, Curses::COLOR_BLACK)
		
		@screen_height = Curses.lines
		@screen_width = Curses.cols
		@central_height = @screen_height / 8
		@central_width = @screen_width / 8
	end
		
	def setup
	
		header_window = Curses::Window.new(1, @screen_width, 0, 0)
		header_window.color_set(2)
		header_window << "Fan with Math".center(@screen_width)
		header_window.refresh

		@main_window = Curses::Window.new(@screen_height - 1, @screen_width, 1, 0)
		@main_window.color_set(1)
		@main_window.keypad(true)
		@main_window.refresh
		
		@game_state = State::HOME
	end
	
	def run
		
		home
		
		buffer = StringIO.new
		while true
			
			input = @main_window.getch
			key = input.to_i
			
			case @game_state
			when State::HOME
				
				if key.between?( \
						  Game::Type::ARITHMETIC, Game::Type::LOGICAL)
					type = key
					level
				elsif key == ESC_KEY
					exit
				end
			
			when State::LEVEL
				
				if key.between?( \
						  Game::Level::STUPID, Game::Level::GENIUS)
					@game = Game.new(type, key)
					game
				elsif key == ESC_KEY
					home
				end
				
			when State::GAME
				
				if key.between?(0, 9)
					buffer << input
					
				elsif key == BACK_KEY
					
					@main_window.delch
					@main_window.setpos(@main_window.cury, @main_window.curx - 1)
					@main_window.delch
					@main_window.setpos(@main_window.cury, @main_window.curx - 1)
					@main_window.delch
					
					if buffer.size > 0
						
						@main_window.setpos(@main_window.cury, @main_window.curx - 1)
						@main_window.delch
					
						buffer = StringIO.new buffer.string[0...buffer.size - 1]
					end
					
				elsif key == ENTER_KEY
					
					@game.store(buffer.string)
					buffer = StringIO.new
					game
					
				elsif key == ESC_KEY
					home
				end
				
			when State::RESULT
				
				if key == ESC_KEY
					home
				end
			end

			@main_window.refresh
		end
	end
	
	def home
		
		Curses.noecho
		@game_state = State::HOME
		@main_window.clear

		@main_window.setpos(@central_height, @central_width)
		@main_window << "1.  \tArithmetic"
		@main_window.setpos(@central_height + 1, @central_width)
		@main_window << "2.  \tLogical"
		@main_window.setpos(@central_height + 3, @central_width)
		@main_window << "Esc.\tExit"
	end
	
	def level
		
		Curses.noecho
		@game_state = State::LEVEL
		@main_window.clear
		
		@main_window.setpos(@central_height, @central_width)
		@main_window << "1.  \tStupid"
		@main_window.setpos(@central_height + 1, @central_width)
		@main_window << "2.  \tNormal"
		@main_window.setpos(@central_height + 2, @central_width)
		@main_window << "3.  \tTalent"
		@main_window.setpos(@central_height + 3, @central_width)
		@main_window << "4.  \tNerd"
		@main_window.setpos(@central_height + 4, @central_width)
		@main_window << "5.  \tGenius"
		@main_window.setpos(@central_height + 6, @central_width)
		@main_window << "Esc.\tBack"
	end
	
	def game
		
		Curses.echo
		@game_state = State::GAME
		@main_window.clear
		@main_window.setpos(@central_height, @central_width)
		
		if (! (cur = @game.current).nil?)
			@main_window << cur
			@main_window << " = "
		else
			result
		end
	end
	
	def result
		
		Curses.noecho
		@game_state = State::RESULT
		@main_window.clear
		
		@main_window.setpos(@central_height, @central_width)
		@main_window << "Results"
		
		idx = 0;
		@game.rallies.each do |exp|
			
			@main_window.color_set(1)
			@main_window.setpos(@central_height + (idx + 2), @central_width)
			
			answer = @game.results.fetch(idx)
			calc = eval(exp).to_s
			valid = ! answer.empty? \
			  && (answer =~ /\A[+-]?\d+?(\.\d+)?\Z/ \
				  || ["true", "false"].include?(answer)) \
			  ? eval("#{exp} == #{answer}") : false
			
			@main_window << exp
			@main_window << " = "
			
			@main_window.color_set(3) if valid
			@main_window << calc
			if (! valid)
				@main_window.color_set(4)
				@main_window << " [#{answer}]"
			end

			idx += 1
		end
		
		@main_window.color_set(1)
	end
end
