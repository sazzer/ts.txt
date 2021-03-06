#!ruby

#   ts.txt - Console based time tracking tool
#   Copyright (C) 2009 Graham Cox <graham@grahamcox.co.uk>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software Foundation,
#   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA


require 'time';

TIMESHEET_FILE=File.expand_path("~/.ts")

action=ARGV.shift;

if (action == "start")
	# Start a new activity
	activity = ARGV.shift;
	time = Time.parse(ARGV.shift || "now");
	puts "Starting " + activity + " at " + time.to_s;
	open(TIMESHEET_FILE, 'a') { |f|
	  f.puts "start|" + time.to_i.to_s + "|" + activity
	}
elsif (action == "stop")
	# Stop the current activity
	time = Time.parse(ARGV.shift || "now");
	puts "Stopping at " + time.to_s;
	open(TIMESHEET_FILE, 'a') { |f|
	  f.puts "stop|" + time.to_i.to_s
	}
elsif (action == "what")
	time = Time.parse(ARGV.shift || "now");
	print "At " + time.to_s + " I was doing: "
	msg = "Nothing"
	File.open(TIMESHEET_FILE).each {|line|
		cols = line.chomp.split("|")
		timepart = cols[1]
		actionpart = cols[0]
		linetime = Time.at(timepart.to_i)
		if (time >= linetime)
			if (actionpart == "start")
				msg = cols[2] + ", started at " + linetime.to_s
			elsif (actionpart == "stop")
				msg = "Nothing. Stopped work at " + linetime.to_s
			end
		end
	}
	print msg
	print "\n"
elsif (action == "list")
	starttime = Time.parse(ARGV.shift || "00:00");
	endtime = Time.parse(ARGV.shift || "now");
	puts "Listing activities between " + starttime.to_s + " and " + endtime.to_s
	File.open(TIMESHEET_FILE).each {|line|
		cols = line.chomp.split("|")
		timepart = cols[1]
		actionpart = cols[0]
		linetime = Time.at(timepart.to_i)
		if (linetime >= starttime and linetime <= endtime)
			if (actionpart == "start")
				msg = cols[2] + ", started at " + linetime.to_s
			elsif (actionpart == "stop")
				msg = "Stopped work at " + linetime.to_s
			end
			puts msg
		end
	}

else
	# Usage instructions
	puts "Time Tracking Client v0.1"
	puts "Graham Cox: <graham@grahamcox.co.uk>"
	puts ""
	puts "Usage: "
	puts "ts start <activity> [<when>]"
	puts "    Start the named activity, at the specified time or now if no time specified"
	puts "ts stop [<when>]"
	puts "    Stop the current activity, at the specified time or now if no time specified"
	puts "ts what [<when>]"
	puts "	  What was I doing at the given time, or now if no time specified"
	puts "ts list <start> [<end>]"
	puts "    List all activities between the given start time, up to the given end time (or now if no time specified)"
end
