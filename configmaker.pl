#!/usr/bin/perl
#
# Script takes template, prompts for variables, and outputs a configuration
#
#
# check to make sure the user specified a template and output file
#
if($#ARGV!=1) {
        die("Syntax Error: makemyconfig templatefile configfile\n");
}

# take note of the file name for the template file
# and the configuration file
$TEMPLATEFILE=$ARGV[0];
$CONFIGFILE=$ARGV[1];

# read the default tags from makemyconfig.conf
#
open(SOURCE,'/usr/local/etc/makemyconfig.conf') || die("cannot open defaults file");
@defaults=<SOURCE>; 
close(SOURCE);
chomp(@defaults);
for($i=0;$i<=$#defaults;$i++) {
        ($key,$val)=split(/=/,$defaults[$i]);
        $subs{$key}=$val;
}

# read in the template
#
open(SOURCE,$TEMPLATEFILE) || 
	die("Cannot open template file $FILE.");
@lines=<SOURCE>;
close(SOURCE);
chomp(@lines);

# search for all the tags, and put them into the subs array
#
for($i=0;$i<=$#lines;$i++) {
        while($lines[$i]=~/(%.*?%)/g)
        {
                if (!exists $subs{$1}) {
                        $subs{$1}="";
                }
        }
}

# prompt the user for the value of all tags,
# allowing them to press enter if a default
# value was specified in makemyconfig.conf
foreach $key (sort((keys %subs))) {
        print "$key ($subs{$key}): ";
        $newval=<stdin>;
        chomp($newval);
        if($newval ne "") {
                $subs{$key}=$newval;
        }
}

# create the configuration file and open it for writing
open(TARGET,">$CONFIGFILE") ||
        die("cannot create config file $CONFIGFILE");

# write the configuration file, substituting the proper
# values for each tag that is encountered
for($i=0;$i<$#lines;$i++) {
        while($lines[$i]=~/(%.*?%)/g) {
                $val=$subs{$1};
                $lines[$i]=~s/$1/$val/g;
        }
        print TARGET "$lines[$i]\n";
}

# close the configuration file, script is complete.
close(TARGET);