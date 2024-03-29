#!c:/perl/bin/perl

use strict;
use warnings;

# Global data array. Will be filled and sorted for easy processing.
my(@RESULTS);

# ---------- Custom parsing code goes here ---------------------------------------

# Every line in @RESULTS should be in the following format
# <YEAR>;<MONTH>;<DAY>;<HOUR>;<MINUTE>;<SECOND>;<LOG_TEXT_LINE>


sub custom_processor {
	
	# Write resultarray to file
	open(FILE,'>log2data.log');
	foreach (@RESULTS) {
	  print FILE $_."\n";
	}
	close(FILE);
	
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
	my($DIR,$de);
	
	print '  '.$dirname."\n";
	
	opendir($DIR,$dirname) or die('Error - Cant open "'.$dirname.'"');
	
	foreach $de (readdir($DIR)) {
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
	my($filedate,$file_yer,$file_mth,$file_day,$line_hur,$line_min,$line_sec,$line_text,$line,$FILE);
	
	print '    '.$filename."\n";
	
	open($FILE,'<'.$filename) or die('Error - Cant open "'.$filename.'"');
	
	# Read first line (date)
	$filedate = <$FILE>;
	$filedate =~ /^(\d{4})-(\d{2})-(\d{2})/;
	$file_yer = $1;
	$file_mth = $2;
	$file_day = $3;
	
	# Read content lines
	while ($line = <$FILE>) {
		$line =~ /^(\d{2}):(\d{2}):(\d{2})\s+(.*)$/;
		$line_hur = $1;
		$line_min = $2;
		$line_sec = $3;
		$line_text = $4;
		
		# Newline (/) = append to current
		while ($line_text =~ /\/$/) {
			chop($line_text);
			$line = $line_text;
			$line = <$FILE>;
			$line =~ /^(\d{2}):(\d{2}):(\d{2})\s+(.*)$/;
			$line_text .= $4;
		}
		
		# Add to result array
		push(@RESULTS,$file_yer.';'.$file_mth.';'.$file_day.';'.$line_hur.';'.$line_min.';'.$line_sec.';'.$line_text);
	}
	
	close($FILE);
}

# --------------------------------------------------------------------------------
