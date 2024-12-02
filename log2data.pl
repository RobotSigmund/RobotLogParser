#!c:/perl/bin/perl

use strict;
use warnings;

# Global data array. Will be filled and sorted for easy processing.
our @RESULTS;



# ---------- Custom parsing code goes here ---------------------------------------

# Every line in @RESULTS should be in the following format
# <YEAR>;<MONTH>;<DAY>;<HOUR>;<MINUTE>;<SECOND>;<LOG_TEXT_LINE>

sub custom_processor {
	
	# Write resultarray to file
	open(my $FILE, '>log2data.log');
	foreach (@RESULTS) {
		print $FILE $_."\n";
	}
	close($FILE);
	
}

# --------------------------------------------------------------------------------



$| = 1;

print 'Scanning folders and subfolders...'."\n";
scandir('.\Logs');

print 'Sorting results...'."\n";
@RESULTS = sort @RESULTS;

print 'Processing results...'."\n";
custom_processor();

print "\n".'DONE! 3 sec to exit...';
sleep(3);

exit;

# --------------------------------------------------------------------------------

sub scandir {
	my($dirname) = @_;
	
	print '  '.$dirname."\n";
	
	opendir(my $DIR, $dirname) or die('Error - Cant open "'.$dirname.'"');
	
	foreach my $de (readdir($DIR)) {
		# Skip '.' and '..'
		next if ($de =~ /^\.{1,2}$/);
		
		if (-d $dirname.'/'.$de) {
			# Recursion for folders
			scandir($dirname.'/'.$de);
			
		} elsif ($de =~ /\.log$/i) {
			# Firprocessing for logfiles
			readlogfile($dirname.'/'.$de);
			
		} else {
			# Nop for others
		}
	}
	
	closedir($DIR);
}

# --------------------------------------------------------------------------------

sub readlogfile {
	my($filename) = @_;
	
	print '    '.$filename."\n";
	
	open(my $FILE,'<'.$filename) or die 'Error: '.$filename.' - Can not open file';
	
	my($file_yer, $file_mth, $file_day);
	
	# Read first line (date)
	if (<$FILE> =~ /^(\d{4})-(\d{2})-(\d{2})/) {
		($file_yer, $file_mth, $file_day) = ($1, $2, $3);
	} else {
		die 'ERROR: '.$filename.' - Does not look like a logfile'."\n";
	}
	
	# Read content lines
	while (my $line = <$FILE>) {
		if (my($line_hur, $line_min, $line_sec, $line_text) = $line =~ /^(\d{2}):(\d{2}):(\d{2})\s+(.*)$/) {
			
			# If text ends with Newline (/) = read next line and append to current
			while ($line_text =~ /\/$/) {
				# Chop off the frontslash (/)
				chop($line_text);
				# Read the next line and extract only the text
				my(undef, undef, undef, $next_line) = <$FILE> =~ /^(\d{2}):(\d{2}):(\d{2})\s+(.*)$/;
				# Append to current line text
				$line_text .= $next_line;
			}
		
			# Add to result array
			push(@RESULTS, $file_yer.';'.$file_mth.';'.$file_day.';'.$line_hur.';'.$line_min.';'.$line_sec.';'.$line_text);
		} else {
			print 'WARNING: '.$filename.' - Line doesn\'t look right ('.$line.')';
		}
	}
	
	close($FILE);
}

# --------------------------------------------------------------------------------
