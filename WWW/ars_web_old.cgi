#!/utiloss/bin/perl5.002
#
#    ars_web.cgi - A Web Client for ARS2.0
#
#    Copyright (C) 1995 Joel Murphy, jmurphy@acsu.buffalo.edu
#                       Jeff Murphy, jcmurphy@acsu.buffalo.edu
# 
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
# 
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
# 
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
# 
#    Comments to: arsperl@smurfland.cit.buffalo.edu

use ARS;
use POSIX;
do 'cgi-lib.pl';

$ARS_SERVER = "";
$ACTIVE_LINKS = "on";
$VERSION = "1.1alpha";

# Styles
$fheight = 10;     # difference in field height required to force to a new line
$menuthresh = 30;  # maximum entries in a menu before using a selection list

#select STDERR;

# Global Variables used
#
# $c = control record of current logged in user
# %input = variables from form
# $state = {SUBMIT,QUERY,MODIFY,LIST,OPEN,COMMIT_SUBMIT,COMMIT_MODIFY,DELETE}
#          current state of form
# $display = true is form is being displayed (and not modified by a link)
# $pstate = previous state of form
# $commit = set if commit button pressed, else an active link
# $message = message from an active link
# @variable = variables inside a macro
# $in_macro = true if executing a macro
# $macro_query = query string from a macro
#

$SIG{HUP} = \catch_signal;
$SIG{INT} = \catch_signal;
$SIG{QUIT} = \catch_signal;
$SIG{ILL} = \catch_signal;
$SIG{FPE} = \catch_signal;
$SIG{KILL} = \catch_signal;
$SIG{BUS} = \catch_signal;
$SIG{SEGV} = \catch_signal;
$SIG{SYS} = \catch_signal;
$SIG{PIPE} = \catch_signal;
$SIG{TERM} = \catch_signal;

sub catch_signal {
    my $sig = shift;

    print STDERR "caught SIG$sig!\n";
    die;
}

%month = ( "JAN" => 0, "FEB" => 1, "MAR" => 2, "APR" => 3, "MAY" => 4,
	   "JUN" => 5, "JUL" => 6, "AUG" => 7, "SEP" => 8, "OCT" => 9,
	   "NOV" => 10, "DEC" => 11, "JANUARY" => 0, "FEBRUARY" => 1,
	   "MARCH" => 2, "APRIL" => 3, "MAY" => 4, "JUNE" => 5, "JULY" => 6,
	   "AUGUST" => 7, "SEPTEMBER" => 8, "OCTOBER" => 9, "NOVEMBER" => 10,
	   "DECEMBER" => 11);

%day = ( "SUN" => 0, "MON" => 1, "TUE" => 2, "WED" => 3, "THU" => 4,
	 "FRI" => 5, "SAT" => 6, "SUNDAY" => 0, "MONDAY" => 1,
	 "TUESDAY" => 2, "WEDNESDAY" => 3, "THURSDAY" => 4, "FRIDAY" => 5,
	 "SATURDAY" => 6);

sub timeconv {
    my $a = shift;
    my $b = localtime($a);
    if (length($a)) {
	return $b;
    } else {
	return "";
    }
}

sub date_string {
    my $ts = shift;
    my $s = localtime($ts);
    my $mday, $mon, $year;
    my @f = split(' ', $a);
    if (defined($day{"\U$f[0]"})) {
	shift @f;
    }
    $mon = $month{"\U$f[0]"};
    $mday = $f[1];
    $year = $f[3] - 1900;
    return "$mon/$mday/$year";
}

sub time_string {
    my $ts = timeconv(shift);
    $ts =~ s/\S*\s*\S*\s*\S*\s*(\S*).*/$1/;
    return $ts;
}

sub weekday_string {
    my $ts = timeconv(shift);
    $ts =~ s/(\S).*/$1/;
    return $ts;
}

sub asc2stamp {
    my $a = shift;
    my $sec, $min, $hour, $mday, $mon, $year, $wday;
    my @f = split(' ', $a);
    if (defined($day{"\U$f[0]"})) {
	$wday = $day{"\U$f[0]"};
	shift @f;
    }
    $mon = $month{"\U$f[0]"};
    $mday = $f[1];
    ($hour, $min, $sec) = split(":",$f[2]);
    $year = $f[3] - 1900;
    return mktime($sec, $min, $hour, $mday, $mon, $year, $wday, 0, -1);
}

# Crash And Burn
sub cab {
    print "<HTML>\n";
    print "<H1>Error</H1>\n";
    print "Your request has failed for the following reason:<BR>\n";
    $msg = shift;
    print $msg."<BR>\n";
    print "</HTML>\n";
    exit 0;
}

#
# return an associative array of the values of all the set fields in the
# form.  It will only report values that changed from the original
# (or default) if $changed is 1.
#
sub get_input {
    my $changed = shift;
    my %vals;
    my $id;
    my $v;
    foreach (keys %input) {
	$id = undef;
	$v = undef;
	if (/^FIELD_(.*)/) {
	    $id = $1;
	    $v = $input{$_};
	} elsif (/^TIME_(.*)/) {
	    $id = $1;
	    # timestamps must be converted from strings
	    if ($changed && ($input{$_} ne $input{"PREV_$id"})) {
		$v = asc2stamp($input{$_});
		$vals{$id} = $v;
	    }
	    next;
	} elsif (/^MENU_(.*)/) {
	    $id = $1;
	    if (length($input{"VALUE_$id"})) {
		$v = $input{"VALUE_$id"}
	    } else {
		$v = $input{$_};
	    }
	} else {
	    next;
	}
	if ($changed && ($v ne $input{"PREV_$id"}) ||
	    (! $changed) && length($v)) {
	    $vals{$id} = $v;
	}
    }
    %vals;
}

#
# get the value for a specific field id
#
sub get_field {
    my $id = shift;
    
    if (defined($input{"FIELD_$id"})) {
	return $input{"FIELD_$id"};
    } elsif (defined($input{"TIME_$id"})) {
	# timestamps must be converted from strings
	return asc2stamp($input{"TIME_$id"});
    } elsif (defined($input{"MENU_$id"})) {
	if (defined($input{"VALUE_$id"})) {
	    return $input{"VALUE_$id"};
	} else {
	    return $input{"MENU_$id"};
	}
    } else {
	return undef;
    }
}

#
# sets the specified field value in %input
#
sub set_field {
    my $id = shift;
    my $val = shift;
    
    if (defined($input{"MENU_${id}"})) {
	$input{"VALUE_${id}"} = $val;
    } elsif (defined($input{"TIME_${id}"})) {
	$input{"TIME_${id}"} = timeconv($val);
    } else {
	# normal value field
	$input{"FIELD_${id}"} = $val;
    }
}

#
# convert a remedy pattern into a perl regular expression
#
sub ars_regex_to_perl {
    # FIX -- escape characters meaningful to perl
    my $e = shift;
    
    $e =~ s/%/.*/;
    $e =~ s/_/./;
    $e = "^$e\$";
    return $e;
}

sub eval_arith {
    my $op = shift;
    my $l, $r;
    
    if (defined($op->{right})) {
	return eval(eval_assignment($op->{left})." $op->{oper} ".eval_assignment($op->{right}));
    } else {
	return eval("$op->{oper} ".eval_assignment($op->{left}));
    }
}

sub eval_arithOp {
    my $op = shift;
    my $l, $r;
    
    if (defined($op->{right})) {
	return eval(eval_FieldValueOrArith($op->{left})." $op->{oper} ".eval_FieldValueOrArith($op->{right}));
    } else {
	return eval("$op->{oper} ".eval_FieldValueOrArith($op->{left}));
    }
}


%functions = ("date", "eval_date",
	      "time", "eval_time",
	      "month", "eval_month",
	      "day", "eval_day",
	      "year", "eval_year",
	      "weekday", "eval_weekday",
	      "hour", "eval_hour",
	      "minute", "eval_minute",
	      "second", "eval_second",
	      "trunc", "eval_trunc",
	      "round", "eval_round",
	      "convert", "eval_convert",
	      "length", "eval_length",
	      "upper", "eval_upper",
	      "lower", "eval_lower",
	      "substr", "eval_substr",
	      "left", "eval_left",
	      "right", "eval_right",
	      "ltrim", "eval_ltrim",
	      "rtrim", "eval_rtrim",
	      "lpad", "eval_lpad",
	      "rpad", "eval_rpad",
	      "replace", "eval_replace",
	      "substr", "eval_substr",
	      "min", "eval_min",
	      "max", "eval_max");

sub eval_date {
    return undef if ($#_ != 0);
    my $date_string = timeconv(shift);
    $date_string = s/(\S*\s*\S*).*(\S*)/$1 $2/;
    return $date_string;
}

sub eval_time {
    return undef if ($#_ != 0);
    my $date_string = timeconv(shift);
    $date_string = s/\S*\s*\S*\s*(\S*).*/$1/;
    return $date_string;
}

sub eval_month {
    return undef if ($#_ != 0);
    my $date_string = timeconv(shift);
    $date_string = s/(\S*).*/$1/;
    return $date_string;
# fix to return number
}

sub eval_day {
    return undef if ($#_ != 0);
    my $date_string = timeconv(shift);
    $date_string = s/\S*\s*(\S*).*/$1/;
    return $date_string;
}

sub eval_year {

}

sub eval_weekday {

}

sub eval_hour {

}

sub eval_minute {

}

sub eval_second {

}

sub eval_trunc {
    
}

sub eval_round {
    
}

sub eval_convert {
    
}

sub eval_length {
    return undef if ($#_ != 0);
    return length(shift);
}

sub eval_upper {
    return undef if ($#_ != 0);
    my $a = shift;
    return "\U$a";
}

sub eval_lower {
    return undef if ($#_ != 0);
    my $a = shift;
    return "\L$a";
}

sub eval_substr {
    if ($#_ == 1) {
	return substr(shift, shift);
    } elsif ($#_ == 2) {
	return substr(shift, shift, shift);
    } else {
	return undef;
    }
}

sub eval_left {
    return undef if ($#_ != 1);
    return substr(shift, 0, shift);
}

sub eval_right {
    return undef if ($#_ != 1);
    my $s = shift;
    return substr($s, length($s) - shift);
}

sub eval_ltrim {
    return undef if ($#_ != 0);
    my $s = shift;
    $s =~ /[ ]*(.*)/;
    return $1;
}

sub eval_rtrim {
    return undef if ($#_ != 0);
    my $s = shift;
    $s =~ s/[ ]*$//;
    return $s;
}

sub eval_lpad {
    
}

sub eval_rpad {
    
}

sub eval_replace {
    return shift;
}

sub eval_substr {
    
}

sub eval_min {
    
}

sub eval_max {
    
}

sub eval_function {
    my $command = shift;
    my $fcn = shift @$command;
    my @args;
    foreach $a (@$command) {
	$args[$#args++] = eval_assignment($a);
    }
    &{$functions{$fcn}}(@args);

}

sub eval_assignment {
    my $struct = shift;
    my $server = $ARS_SERVER;
    my $schema = $input{SCHEMA};
    my $sess;
    my @l, %f;
    my $val;
    if (defined($struct->{value})) {
	$struct->{value};
    } elsif (defined($struct->{field})) {
	if ($struct->{field}{server} eq "*") {
	    # field from form
	    if (defined($struct->{field}{fieldId})) {
		return get_field($struct->{field}{fieldId});
	    } else {
		return undef;
	    }
	} else {
	    # field from database
	    if ($struct->{field}{server} ne "@") {
		$server = $struct->{field}{server};
	    }
	    if ($struct->{field}{schema} ne "@") {
		$schema = $struct->{field}{schema};
	    }
	    ($sess = ars_Login($server, $input{USERNAME}, $input{PASSWORD})) ||
		return undef;	    # fail
	    @l = ars_GetListEntry($sess, $schema, $struct->{field}{qualifier}, 0);
	    if ($#l > 0) {
		$message .= "Warning: more than one match for query\n<BR>";
	    }
	    if ($#l < 0) {
		$message .= "Warning: less than one match for query\n<BR>";
		return undef;
	    }
	    if (defined($struct->{field}{fieldId})) {
		my $id = $struct->{field}{fieldId};
		(%f = ars_GetEntry($sess, $schema, $l[0], $id)) || return undef;
		return $f{$id};
	    }
	}
    } elsif (defined($struct->{process})) {
	print STDERR "$input{USERNAME} tried to run $struct->{process}\n";
    } elsif (defined($struct->{arith})) {
	return eval_arith($struct->{arith});
    } elsif (defined($struct->{function})) {
	return eval_function($struct->{function});
    } elsif (defined($struct->{dde})) {
	;
    } else {
	return undef;
    }
}

sub build_macro_query {
    my $cmds = shift;
    my $parms = shift;
    my $server = shift;
    my $schema = shift;
    my @cmds;
    my $field, $id, $val, $cur_val, $fid;
    my $i;
    my $sess;
    my $qs;
    
    @cmd = split("\001",$cmds);
    $qs = "1 = 1";
    for ($i=0; $i<=$#cmd; $i++) {
	next if (! length($cmd[$i]));
	($id, $val) = split("=", $cmd[$i]);
	# replace macro arguments with values
	print STDERR join(",",%$parms);
	foreach (keys %$parms) {
	    print STDERR "replace: $_ => $parms->{$_}\n";
	    $val =~ s/[\$]\Q$_\E[\$]/$parms->{$_}/;
	}
	# fill in field values ($-1$ is NULL)
	# FIX!!! this will do recursive replacements
	while ($val =~ /[\$](.*?)[\$]/) {
	    $fid = $1;
	    $cur_val = get_field($1);
	    print STDERR "replace: $fid => $cur_val\n";
	    $val =~ s/[\$]$fid[\$]/$cur_val/;
	}
	$sess = ars_Login($server,$input{USERNAME},$input{PASSWORD});
	$field = ars_GetField($sess, $schema, $id);
	# quote strings
	if ($field->{dataType} eq "char" ||
	    $field->{dataType} eq "diary") {
	    $val = "\"$val\"";
	} else {
	    if (! length($val)) {
		$val = 0;
	    }
	}
	$qs = "($qs) AND '$id'=$val";
    }
    print STDERR "query_string: $qs \n";
    ars_Logoff($sess);    
    return $qs;
}

sub build_macro_vals {
    my $cmds = shift;
    my $parms = shift;
    my @cmds;
    my $id, $val;
    my $i;
    my %vals;
    
    @cmd = split("\001",$cmds);
    for ($i=0; $i<=$#cmd; $i++) {
	next if (! length($cmd[$i]));
	($id, $val) = split("=", $cmd[$i]);
	# replace macro arguments with values
	print STDERR "id $id\n";
	print STDERR "val: $val\n";
	foreach (keys %$parms) {
	    print STDERR "replace: $_ => $parms->{$_}\n";
	    $val =~ s/[\$]\Q$_\E[\$]/$parms->{$_}/;
	}
	print STDERR "val2: $val\n";
	# fill in field values ($-1$ is NULL)
	# FIX!!! this will do recursive replacements
	while ($val =~ /[\$](.*?)[\$]/) {
	    $fid = $1;
	    $cur_val = get_field($1);
	    print STDERR "replace2: $fid => $cur_val\n";
	    $val =~ s/[\$]$fid[\$]/$cur_val/;
	}
	print STDERR "val3: $val\n";
	$vals{$id} = $val;
    }
    return %vals;
}

sub get_defaults {
    my $control = shift;
    my $schema = shift;
    my %vals, $field;
    
    foreach (ars_GetListField($control, $schema)) {
	($field = ars_GetField($c, $input{SCHEMA}, $_)) || return undef;
	$vals{$field->{fieldId}} = eval_value($field->{defaultVal});
    }
    return %vals;
}

sub do_action {
    my $ac = shift;
    
    if (defined($ac->{macro})) {
	# the structure for macros is really strange
	# I can only guess that this is correct
	my $server, $schema;
	my $parms = $ac->{macro}{macroParms};
	my $text = $ac->{macro}{macroText};
	my $ss, $cmds;
	my $open_it = "";
	my $do_it ="";
	my %v;
	my $sess;
	
	print STDERR "parmsx: ".join(",",%$parms)."\n";
	# do parameter assignment
	foreach (split(/[\n\r]+/,$text)) {
	    if ($_ =~ /^Set-schema: (.*)/) {
		($schema, $server) = split("\001", $1);
	    } elsif ($_ =~ /^Submit-display: (.*)/) {
		print STDERR "hmmm: $1\n";
		$open_it = "SUBMIT";
		($ss, $cmds) = split(/\|/,$1);
		($schema, $server) = split("\001", $ss);
		$sess = ars_Login($server, $input{USERNAME}, $input{PASSWORD});
		%v = get_defaults($sess, $schema);
		%v = (%v, build_macro_vals($cmds, $parms));
		ars_Logoff($sess);
	    } elsif ($_ =~ /^Query-display: (.*)/) {
		$open_it = "QUERY";
		($schema, $server) = split("\001", $1);
	    } elsif ($_ =~ /^Submit: (.*)/) {
		$do_it = "SUBMIT";
		($ss, $cmds) = split("|",$1);
		($schema, $server) = split("\001", $ss);
		$sess = ars_Login($server, $input{USERNAME}, $input{PASSWORD});
		%v = get_defaults($sess, $schema);
		%v = (%v, build_macro_vals($cmds, $parms));
		ars_Logoff($sess);
	    } elsif ($_ =~ /^Query: (.*)/) {
		$cmds = $1;
		if (!$cmds) {
		    $open_it = "QUERY" if (!$open_it);
		} else {
		    $macro_query = build_macro_query($cmds,$parms,$server,$schema);
		}
	    } elsif ($_ =~ /^Entry-list: (.*)/) {
		$open_it = "LIST";
	    } elsif ($_ =~ /^Report: (.*)/) {
		# !!!??????
	    } elsif ($_ =~ /^window-position: (.*)/) {
		# nothing to do here
	    } elsif ($_ =~ /^end$/) {
		last;
	    }
	}
	if ($do_it) {
	    if ($do_it eq "SUBMIT") {
		$sess = ars_Login($server, $input{USERNAME}, $input{PASSWORD});
		(ars_CreateEntry($sess, $schema, %v) ||
		 ($message .= "Unable to do submit inside macro.<BR>\n"));
	    }
	} elsif ($open_it) {
	    $state = $open_it;
	    $in_macro = 1;
	    $ARS_SERVER = $server;
	    $input{SCHEMA} = $schema;
	    %vals = %v;
	    print STDERR "state: $state\n";
	    print STDERR "server: $server\n";
	    print STDERR "schema: $schema\n";
	    print STDERR "vals: ".join(",",%vals)."\n";
	}
    } elsif (defined($ac->{assign_fields})) {
	foreach (@{$ac->{assign_fields}}) {
	    set_field($_->{fieldId}, eval_assignment($_->{assignment}));
	}
    } elsif (defined($ac->{process})) {
	;
    } elsif (defined($ac->{message})) {
	$message .= $ac->{message}."<BR>";
    } elsif (defined($ac->{characteristics})) {
	;
    } elsif (defined($ac->{dde})) {
	;
    }
}

sub eval_value {
    my $v = shift;
    my $default = shift;
    my $ts;
    
    if ($v =~ /^\0/) {
	if ($v eq "\0default\0") {
	    return $default;
	} elsif ($v eq "\0user\0") {
	    return $input{USERNAME};
	} elsif ($v eq "\0timestamp\0") {
	    return time;
	} elsif ($v eq "\0time\0") {
	    return time_string(time);
	} elsif ($v eq "\0date\0") {
	    return date_string(time);
	} elsif ($v eq "\0schema\0") {
	    return $input{SCHEMA};
	} elsif ($v eq "\0server\0") {
	    return $ARS_SERVER;
	} elsif ($v eq "\0weekday\0") {
	    return weekday_string(time);
	} elsif ($v eq "\0groups\0") {
	    # retrieve group list from User schema
	    my $entry, $field, %val;
	    ($entry) = ars_GetListEntry($c,"User",ars_LoadQualifier($c, "User", "'Login Name' = \"$input{USERNAME}\""), 1);
	    $field = ars_GetFieldByName($c, "User", "Group list");
	    %val = ars_GetEntry($c,"User",$entry,$field);
	    return $val{$field};
	} elsif ($v eq "\0operation\0") {
	    # FIX ??
	    if ($state eq "SUBMIT" || $state eq "COMMIT_SUBMIT") {
		return "CREATE";
	    } elsif ($state eq "LIST") {
		return "GET LIST";
	    } elsif ($state eq "MODIFY" || $state eq "COMMIT_MODIFY") {
		return "SET";
	    } elsif ($state eq "DELETE") {
		return "DELETE";
	    } elsif ($state eq "QUERY" || $state eq "LIST") {
		return "QUERY";
	    }
	    print STDERR "unknown operation\n";
	    return undef;
	} elsif ($v eq "\0hardware\0") {
	    chomp(my $h=`uname -m`);
	    return $h;
	} elsif ($v eq "\0os\0") {
	    chomp(my $h=`uname -a`);
	    return $h;
	}
	print STDERR "unknown variable\n";
	return undef;
    }
    return $v;
}

sub eval_StatHistory {
    my $r = shift;

    if (defined($r->{userOrTime})) {
	return $r->{userOrTime};
    } elsif (defined($r->{enumVal})) {
	return $r->{enumVal};
    }
    return undef;
}

sub eval_queryValue {
    my $r = shift;
    my $sess, @l, %f, @v;
    
    # field from database
    my $server = $rruct->{field}{server};
    my $schema = $struct->{field}{schema};
    ($sess = ars_Login($r->{server}, $input{USERNAME}, $input{PASSWORD})) ||
	return undef;	    # fail
    @l = ars_GetListEntry($sess, $r->{schema}, $r->{qualifier});
    if ($#l < 0) {
	$message .= "Warning: less than one match for query\n<BR>";
	ars_Logoff($sess);
	return undef;
    }
    if ($#l > 0) {
	if ($r->{multi} eq "error") {
	    $message .= "Warning: more than one match for query\n<BR>";
	    ars_Logoff($sess);
	    return undef;
	} elsif ($r->{multi} eq "set") {
	    foreach(@l) {
		%f = ars_GetEntry($sess,$r->{schema},$_,$r->{valueField});
		@v = (@v, $f{$r->{valueField}});
	    }
	    return @v;
	    ars_Logoff($sess);
	}
	# fall through for "first"
    }
    %f = ars_GetEntry($sess,$r->{schema},$l[0],$r->{valueField});
    ars_Logoff($sess);
    return $f{$r->{valueField}};
}

sub eval_FieldValueOrArith {
    my $r = shift;
    
    if (defined($r->{fieldId})) {
	return get_field($r->{fieldId});
    } elsif (defined($r->{value})) {
	return eval_value($r->{value});
    } elsif (defined($r->{arith})) {
	return eval_arithOp($r->{arith});
    } elsif (defined($r->{statHistory})) {
	return eval_StatHistory($r->{statHistory});
    } elsif (defined($r->{valueSet})) {
	my @a;
	foreach (@{$r->{valueSet}}) {
	    @a = (@a, eval_value($_));
	}
	return \@a;
    } elsif (defined($r->{variable})) {
	print STDERR "want variable $r->{variable}\n";
	return $variable[$r->{variable}];
    } elsif (defined($r->{queryValue})) {
	return eval_queryValue($r->{queryValue});
    } elsif (defined($r->{queryCurrent})) {
	return get_field($r->{queryCurrent});
    }
    return undef;
}

# values wanted from <=> and cmp operators
# used by eval_rel_op
%comparisons = ("=="	=> " == 0",
		">"	=> " > 0",
		">="	=> " >= 0",
		"<"	=> " < 0",
		"<="	=> " <= 0",
		"!="	=> " != 0");

sub eval_rel_op {
    my $r = shift;
    my $left = eval_FieldValueOrArith($r->{left});
    my $right = eval_FieldValueOrArith($r->{right});
    
    print STDERR "$left $r->{oper} $right\n";
    if ($r->{oper} eq "like") {
	my $expr = ars_regex_to_perl($right);
	return ($left =~ /$expr/);
    } elsif ($r->{oper} eq "in") {
	return grep {$_ eq $left} @$right;
    } else {
	if ((!defined($left) || isa_string($left)) &&
	    (!defined($right) || isa_string($right))) {
	    # string comparison
	    return eval("('$left' cmp '$right') $comparisons{$r->{oper}}");
	} elsif (isa_string($left) || isa_string($right)) {
	    # FIX -- illegal comparison
	    return 0;
	} else {
	    # numeric comparison
	    $left = 0 if (!defined($left));
	    $right = 0 if (!defined($right));
	    return eval("($left <=> $right) $comparisons{$r->{oper}}");
	}
    }
}

sub eval_qualifier {
    my $q = shift;
    
    print STDERR "$q->{left} $q->{oper} $q->{right}\n";
    if ($q->{oper} eq "and") {
	return eval_qualifier($q->{left}) && eval_qualifier($q->{right});
    } elsif ($q->{oper} eq "or") {
	return eval_qualifier($q->{left}) || eval_qualifier($q->{right});
    } elsif ($q->{oper} eq "not") {
	return ! eval_qualifier($q->{not});
    } elsif ($q->{oper} eq "rel_op") {
	return eval_rel_op($q->{rel_op});
    }
    return 1; # no qualifier is always true
}

sub do_active_link {
    my $name = shift;
    my $a = shift;
    my $all = shift;
    my $qual;
    my $mask;
    my $button;
    
    # determine if a button with the same label has been pressed
    $button = grep {($a->{displayList}[0]{label} eq $_->{displayList}[0]{label}) && $input{"BUTTON_$_->{name}"}} @$all;
    if ($a->{enable}) {
	$mask = $a->{executeMask};
	# check execution mask and query and execute link if true	
	print STDERR "1 $name $mask\n";
	if (((($ARS::AR_EXECUTE_ON_BUTTON & $mask) && $button) ||
	     (($ARS::AR_EXECUTE_ON_SUBMIT & $mask) && $state eq "COMMIT_SUBMIT") ||
	     (($ARS::AR_EXECUTE_ON_MODIFY & $mask) && $state eq "COMMIT_MODIFY") ||
#	     (($ARS::AR_EXECUTE_ON_QUERY & $mask) && $state eq "LIST") ||
	     (($ARS::AR_EXECUTE_ON_DISPLAY & $mask) && $display)) &&
	    eval_qualifier(ars_perl_qualifier($a->{query}))) {
	    print STDERR "2 $name $mask\n";
	    # execute each action for active link
	    foreach (@{$a->{actionList}}) {
		do_action($_);
	    }
	}
    }
}

sub draw_row {
    my $line = shift;
    my $vals = shift;

    # sort line of fields horizontaly
    @line = sort {$a->{displayList}[0]{x} <=> $b->{displayList}[0]{x}} @$line;
    foreach (@line) {
	if (defined($_->{fieldId})) {
	    if ($_->{displayList}[0]{option} eq "HIDDEN") {
		# hidden field
		print "<INPUT TYPE=HIDDEN NAME=\"FIELD_$_->{fieldId}\" VALUE=\"$vals->{$_->{fieldId}}\"> ";
		# store previous value for modify
		if ($state eq "MODIFY") {
		    print "<INPUT TYPE=\"HIDDEN\" NAME=\"PREV_$_->{fieldId}\" VALUE=\"$vals->{$_->{fieldId}}\">";
		}
		next;
	    }
	    print "$_->{displayList}[0]{label} ";
	    if ($_->{fieldId} == 102) {
		# password field
		print "<INPUT TYPE=\"PASSWORD\" NAME=\"FIELD_$_->{fieldId}\" VALUE=\"$vals->{$_->{fieldId}}\" SIZE=12> ";
		# store previous value for modify
		if ($state eq "MODIFY") {
		    print "<INPUT TYPE=\"HIDDEN\" NAME=\"PREV_$_->{fieldId}\" VALUE=\"$vals->{$_->{fieldId}}\">";
		}
	    } elsif ($_->{dataType} eq "integer" ||
		$_->{dataType} eq "real" ||
		$_->{dataType} eq "bitmask") {
		print "<INPUT NAME=\"FIELD_$_->{fieldId}\" VALUE=\"$vals->{$_->{fieldId}}\" SIZE=12> ";
		# store previous value for modify
		if ($state eq "MODIFY") {
		    print "<INPUT TYPE=\"HIDDEN\" NAME=\"PREV_$_->{fieldId}\" VALUE=\"$vals->{$_->{fieldId}}\">";
		}
	    } elsif ($_->{dataType} eq "keyword") {
		print "<INPUT NAME=\"FIELD_$_->{fieldId}\" VALUE=\"$vals->{$_->{fieldId}}\" SIZE=20> ";
		# store previous value for modify
		if ($state eq "MODIFY") {
		    print "<INPUT TYPE=\"HIDDEN\" NAME=\"PREV_$_->{fieldId}\" VALUE=\"$vals->{$_->{fieldId}}\">";
		}
	    } elsif ($_->{dataType} eq "char") {
		# character type
		if (! $_->{limit}) {
		    next;
		    # FIX -- it crashes in the next line if limit
		    #        is undef
		}
		if ($_->{limit}{charMenu}) {
		    # character menu
		    @m = ars_simpleMenu(ars_GetCharMenuItems($c, $_->{limit}{charMenu}));
		    if (! length($_->{limit}{pattern})) {
			# value not restricted to menu
			print "<INPUT NAME=\"VALUE_$_->{fieldId}\" MAXLENGTH=$_->{limit}{maxLength} SIZE=$_->{displayList}[0]{length} VALUE=\"$vals->{$_->{fieldId}}\">";
		    }
		    if ($#m / 2 > $menuthresh) {
			print "<SELECT SIZE=2 NAME=\"MENU_$_->{fieldId}\">";
			print "<OPTION VALUE=\"\">\n";
		    } else {
			print "<SELECT NAME=\"MENU_$_->{fieldId}\">";
			print "<OPTION VALUE=\"\">\n";
		    }
		    while (($name, $value, @m) = @m) {
			if ($value eq $vals->{$_->{fieldId}}) {
			    print "<OPTION VALUE=\"$value\" CHECKED> $name\n";
			} else {
			    print "<OPTION VALUE=\"$value\"> $name\n";
			}
		    }
		    print "</SELECT>";
		} else {
		    print "<INPUT NAME=\"FIELD_$_->{fieldId}\" MAXLENGTH=$_->{limit}{maxLength} SIZE=$_->{displayList}[0]{length} VALUE=\"$vals->{$_->{fieldId}}\"> ";
		}
		# store previous value for modify
		if ($state eq "MODIFY") {
		    print "<INPUT TYPE=\"HIDDEN\" NAME=\"PREV_$_->{fieldId}\" VALUE=\"$vals->{$_->{fieldId}}\">";
		}
	    } elsif ($_->{dataType} eq "diary") {
		# don't put data from diary in field
		print "<TEXTAREA ROWS=5 COLS=30 NAME=\"FIELD_$_->{fieldId}\" VALUE=\"\"></TEXTAREA> ";
		# store previous value for modify
		if ($state eq "MODIFY") {
		    print "<INPUT TYPE=\"HIDDEN\" NAME=\"PREV_$_->{fieldId}\" VALUE=\"\">";
		}
		# nothing to view if you're in a submit window
		if ($state ne "SUBMIT") {
		    print "<INPUT TYPE=\"SUBMIT\" NAME=\"DIARY_$_->{fieldId}\" VALUE=\"view diary\">";
		}
	    } elsif ($_->{dataType} eq "time") {
		# date and time (unix timestamp)
		$timestring = timeconv($vals->{$_->{fieldId}});
#			    if ($vals->{$_->{fieldId}}) {
		print "<INPUT NAME=\"TIME_$_->{fieldId}\" SIZE=20 VALUE=\"$timestring\"> ";
#			    } else {
#				print "<INPUT NAME=\"FIELD_$_->{fieldId}\" SIZE=20 VALUE=\"\"> ";
#			    }
		# store previous value for modify
		if ($state eq "MODIFY") {
		    print "<INPUT TYPE=\"HIDDEN\" NAME=\"PREV_$_->{fieldId}\" VALUE=\"$timestring\">";
		}
	    } elsif ($_->{dataType} eq "enum") {
		# enumerated type
		$m = $_->{limit};
		$i = 0;
		if ($_->{displayList}[0]{type} != 5) {
		    # menu style
		    print "<SELECT NAME=\"FIELD_$_->{fieldId}\">\n";
		    print "<OPTION VALUE=\"\">\n";
		    while ($i <= $#{$m}) {
			if ($i eq $vals->{$_->{fieldId}}) {
			    print "<OPTION VALUE=\"$i\" SELECTED> $m->[$i]\n";
			} else {
			    print "<OPTION VALUE=\"$i\"> $m->[$i]\n";
			}
			$i = $i + 1;
		    }
		    print "</SELECT>";
		} else {
		    # radio button style
		    while ($i <= $#{$m}) {
			if ($i eq $vals->{$_->{fieldId}}) {
			    print "<INPUT TYPE=\"RADIO\" NAME=\"FIELD_$_->{fieldId}\" VALUE=\"$i\" CHECKED> $m->[$i]";
			} else {
			    print "<INPUT TYPE=\"RADIO\" NAME=\"FIELD_$_->{fieldId}\" VALUE=\"$i\"> $m->[$i]";
			}
			$i = $i + 1;
		    }
		}
		# store previous value for modify
		if ($state eq "MODIFY") {
		    print "<INPUT TYPE=\"HIDDEN\" NAME=\"PREV_$_->{fieldId}\" VALUE=\"$vals->{$_->{fieldId}}\">";
		}
	    } elsif ($_->{dataType} eq "null") {
		;
	    } else {
		print "??? ";
	    }
#		    print "$#{$_->{displayList}} ";
	} else {
	    # active link
	    if (($_->{displayList}[0]{option} eq "VISIBLE") &&
		($_->{executeMask} & $ARS::AR_EXECUTE_ON_BUTTON)) {
		print "<INPUT TYPE=\"SUBMIT\" VALUE=\"$_->{displayList}[0]{label}\" NAME=\"BUTTON_$_->{name}\">";
	    }
	    print "<INPUT TYPE=\"HIDDEN\" NAME=\"ACTIVE_$_->{name}\" VALUE=\"1\">";
	}
    }
    print "<BR>\n";
}

sub draw_schema {
    my $fields = shift;
    my $vals = shift;
    
#    print @$fields;
    # sort fields vertically
    @fields = sort {$a->{displayList}[0]{y} <=> $b->{displayList}[0]{y}} (@$fields);
    $#line=-1;
    $py = $fields[0]->{displayList}[0]{y};
    foreach (@fields) {
	$cy = $_->{displayList}[0]{y};
	if (abs($cy-$py) <= $fheight) {
	    $line[$#line+1] = $_;
	} else {
	    draw_row(\@line, $vals);
	    @line=($_);
	}
	$py = $cy;
    }
    draw_row(\@line, $vals);
}


#
#
#

sub main {
    print "Content-type: text/html\n\n";
    
    if (ReadParse(*input)) {
	($c = ars_Login($ARS_SERVER,$input{USERNAME},$input{PASSWORD})) ||
	    cab("Login failed");
	$state = $input{STATE};
	$pstate = $input{PSTATE};
	$commit = defined($input{COMMIT});
	
	$display = 1;
	if (grep(/^BUTTON_/,keys %input)) {
	    # active link -- not a commit
	    # also retain values below
	    $state = $pstate;
	    $display = 0;
	} elsif (($diary) = grep(/^DIARY_/, keys %input)) {
	    $diary =~ s/^DIARY_//;
	    $state = "VIEW_DIARY";
	}
	if ($ACTIVE_LINKS) {
	    # check for active links
	    foreach (grep(/^ACTIVE_/,keys %input)) {
		$_ =~ s/^ACTIVE_//;
		($a = ars_GetActiveLink($c,"$_")) ||
		    cab("can't load active link\n");
		$links{$_} = $a;
	    }
	    # execute active links in order
	    my @links = values %links;
	    foreach (sort {$links{$a}{order} <=> $links{$b}{order}} keys %links) {
		do_active_link($_, $links{$_}, \@links);
	    }
	}
	if (! $in_macro) {
	    # retain previous values
	    if (grep(/^BUTTON_/,keys %input)) {
		%vals = get_input(0);
	    }
	}
	if ($state eq "OPEN") {
	    (@schemas = ars_GetListSchema($c)) ||
		cab("Get schema list failed.");
	    print <<EOF;
<html>
 <H1> Open Schema </H1>
 <FORM METHOD="POST" ACTION="ars_web.cgi">
  <INPUT TYPE="HIDDEN" NAME="USERNAME" VALUE="${input{USERNAME}}">
  <INPUT TYPE="HIDDEN" NAME="PASSWORD" VALUE="${input{PASSWORD}}">
  <INPUT TYPE="HIDDEN" NAME="PSTATE" VALUE="OPEN">
  Action:
  <INPUT TYPE="RADIO" NAME="STATE" VALUE="QUERY" CHECKED> Query
  <INPUT TYPE="RADIO" NAME="STATE" VALUE="SUBMIT"> Submit
  <BR>
  <SELECT NAME="SCHEMA" SIZE=10>
EOF
            foreach(sort(@schemas)) {
		print "<OPTION VALUE=\"${_}\"> ${_}\n";
	    }
	    print "</SELECT><BR>\n";
	    print " <INPUT TYPE=\"SUBMIT\" NAME=\"COMMIT\" VALUE=\"Open\"> <INPUT TYPE=\"RESET\" Value=\"Cancel\"><BR>\n";
	    print "</FORM>\n";
	    print "</html>\n";
	} elsif ($state eq "VIEW_DIARY") {
	    (($id, $field) = ars_GetEntry($c, $input{SCHEMA}, $input{ENTRYID}, $diary)) || cab("Get field failed.");
	    print "<OL>\n";
	    foreach (@$field) {
		print "<LI> <A HREF=\"#$_->{timestamp}\"> $_->{user} ".timeconv($_->{timestamp})." </A>\n";
	    }
	    print "</OL><BR>\n";
	    foreach (@$field) {
		print "<B><A NAME=\"$_->{timestamp}\"> $_->{user} ".timeconv($_->{timestamp})." </A></B>\n";
		print "<DL><PRE>\n$_->{value}\n </PRE></DL><BR>\n";
	    }
	} elsif ($state eq "QUERY" ||
		 $state eq "MODIFY" ||
		 $state eq "SUBMIT") {
	    # get default values from database
	    if (length($input{ENTRYID}) && ($state ne "SUBMIT")) {
		(%vals = ars_GetEntry($c, $input{SCHEMA}, $input{ENTRYID})) ||
		    cab("Get entry failed.");
	    }
	    
	    # get schema layout from server
	    (@f = ars_GetListField($c, $input{SCHEMA})) ||
		cab("Get list field failed");
	    @al = ars_GetListActiveLink($c, $input{SCHEMA});
#	print STDERR join(",",@al);
	    $#field=-1;
	    foreach (@f) {
		($field[$#field+1] = ars_GetField($c, $input{SCHEMA}, $_)) ||
		    cab("Get field failed.");
	    }
	    $#active=-1;
	    if ($ACTIVE_LINKS) {
		foreach(@al) {
		    push @active, ars_GetActiveLink($c, $_);
		}
	    }
	    if (! $in_macro) {
		# if submit then set default values to schema defaults
		if ($state eq "SUBMIT") {
		    foreach (@field) {
			$vals{$_->{fieldId}} = eval_value($_->{defaultVal});
		    }
		}
	    }

	    # print out common header
	    print <<EOF;
<html>
 <H1> $input{SCHEMA} </H1>
 <HR>
 $message
 <HR>
 <FORM METHOD="POST" ACTION="ars_web.cgi">
 <INPUT TYPE="HIDDEN" NAME="USERNAME" VALUE="${input{USERNAME}}">
 <INPUT TYPE="HIDDEN" NAME="PASSWORD" VALUE="${input{PASSWORD}}">
 <INPUT TYPE="HIDDEN" NAME="SCHEMA" VALUE="$input{SCHEMA}">
 <INPUT TYPE="HIDDEN" NAME="ENTRYID" VALUE="$input{ENTRYID}">
 <INPUT TYPE="HIDDEN" NAME="PSTATE" VALUE="${state}">
EOF

            # print out state specific data
            if ($state eq "QUERY") {
		print <<EOF;
 Max List Entries <INPUT NAME="MAXENTRIES" VALUE="100"><BR>
 Action:
 <INPUT TYPE="RADIO" NAME="STATE" VALUE="LIST" CHECKED> List
 <INPUT TYPE="RADIO" NAME="STATE" VALUE="MODIFY"> Modify<BR>
 <INPUT TYPE=\"SUBMIT\" NAME=\"COMMIT\" VALUE=\"Commit\"> <INPUT TYPE=\"RESET\" VALUE=\"Clear\">
 <BR>
 <PRE>
 Query String <INPUT NAME="QUERYSTRING" SIZE=60 MAXLENGTH=120>
 <HR>
EOF
            } elsif ($state eq "SUBMIT") {
		print <<EOF;
 <INPUT TYPE="HIDDEN" NAME="STATE" VALUE="COMMIT_SUBMIT">
 <INPUT TYPE=\"SUBMIT\" NAME=\"COMMIT\" VALUE=\"Submit\"> <INPUT TYPE=\"RESET\" VALUE=\"Clear\">
 <HR>
 <PRE>
EOF
	    } elsif ($state eq "MODIFY") {
		print <<EOF;
 <INPUT TYPE="HIDDEN" NAME="STATE" VALUE="COMMIT_MODIFY">
 <INPUT TYPE=\"SUBMIT\" NAME=\"COMMIT\" VALUE=\"Modify\"> <INPUT TYPE=\"RESET\" VALUE=\"Clear\">
 <HR>
 <PRE>
EOF
	    }
	
	    # print out the actual form
	    @field = (@field, @active);
	    draw_schema(\@field,\%vals);
	} elsif ($state eq "LIST") {
	    # build query string
	    if ($in_macro) {
		$query_string = $macro_query;
	    } else {
		$query_string = $input{QUERYSTRING};
		$query_string = "1 = 1" if (! length($query_string)); # Always true
		%vals = get_input(1);
		foreach (keys %vals) {
		    if ($vals{$_} == 0 && ($vals{$_} !~ /^[0\.]*$/)) {
			# its a string comparison
			$query_string = "( $query_string ) AND '$_' = \"$vals{$_}\"";
		    } else {
			# its a numeric comparison
			$query_string = "( $query_string ) AND '$_' = $vals{$_}";
		    }
		}
	    }
	    print <<EOF;
<html>
 <H1> $input{SCHEMA} </H1>
 <HR>
 <FORM METHOD="POST" ACTION="ars_web.cgi">
 <INPUT TYPE="HIDDEN" NAME="USERNAME" VALUE="${input{USERNAME}}">
 <INPUT TYPE="HIDDEN" NAME="PASSWORD" VALUE="${input{PASSWORD}}">
 <INPUT TYPE="HIDDEN" NAME="SCHEMA" VALUE="$input{SCHEMA}">
 <INPUT TYPE="HIDDEN" NAME="PSTATE" VALUE="${state}">
 Max List Entries <INPUT NAME="MAXENTRIES" VALUE="$input{MAXENTRIES}"><BR>
 Action:
 <INPUT TYPE="RADIO" NAME="STATE" VALUE="QUERY" CHECKED> Query
 <INPUT TYPE="RADIO" NAME="STATE" VALUE="MODIFY"> Modify
 <INPUT TYPE="RADIO" NAME="STATE" VALUE="DELETE"> Delete<BR>
 <INPUT TYPE=\"SUBMIT\" NAME=\"COMMIT\" VALUE=\"Commit\"> <INPUT TYPE=\"RESET\" VALUE=\"Clear\">
 <BR>
 <PRE>
 Query String: $query_string
 </PRE>
 <HR>
EOF
            $q = ars_LoadQualifier($c, $input{SCHEMA}, $query_string);
	    if (! $q) {
		print "Invalid Query String.\n";
		print "</HTML>";
		exit(0);
	    }
	    @l = ars_GetListEntry($c, $input{SCHEMA}, $q, $input{MAXENTRIES});
	    if (! @l) {
		print "Query failed or no matches found.<BR>\n";
		$err = $ars_errstr;
		$err =~ s/\n/<BR>\n/g;
		print "$ars_errstr\n";
		print "</HTML>";
		exit(0);
	    }
	    print "<PRE><SELECT NAME=\"ENTRYID\" SIZE=10>";
	    while (($entry, $descr, @l) = @l) {
		print "<OPTION VALUE=\"$entry\"> $entry $descr\n";
	    }
	    print "</SELECT></PRE><BR>\n";
	} elsif ($state eq "COMMIT_SUBMIT") {
	    @vals = get_input(0);
	    
	    $entry_id = ars_CreateEntry($c, $input{SCHEMA}, @vals);
	    if (length($entry_id)) {
		print "Your submission was successful.  Entry_Id = $entry_id\n";
	    } else {
		$err = $ars_errstr;
		$err =~ s/\n/<BR>\n/g;
		print "submission failed:<BR>\n$err\n";
	    }
	} elsif ($state eq "COMMIT_MODIFY") {
	    %vals = get_input(1);
	    
	    $entry_id = $input{ENTRYID};
	    (ars_SetEntry($c, $input{SCHEMA}, $entry_id, 0, %vals)) ||
		cab ($ars_errstr);
	    print <<EOF;
<html>
Your update has been successful.\n
</html>
EOF
        } elsif ($state eq "DELETE") {
	    (ars_DeleteEntry($c, $input{SCHEMA}, $input{ENTRYID}) != -1) ||
		cab($ars_errstr);
	    print <<EOF;
<html>
The record has been deleted.
</html>
EOF
        } else {
	    cab("Invalid State \"$state\".");
	}
    } else {
	print <<EOF;
<html>
<H1> ARS Login </H1>
<FORM METHOD="POST" ACTION="ars_web.cgi">
 <INPUT TYPE="HIDDEN" NAME="STATE" VALUE="OPEN">
 User Name <INPUT TYPE="TEXT" NAME="USERNAME"><BR>
 Password <INPUT TYPE="PASSWORD" NAME="PASSWORD"><BR><BR>
 <INPUT TYPE="SUBMIT" VALUE=\"Enter System\"> <INPUT TYPE="RESET" VALUE=\"Clear\"><BR>
 </FORM>
 <PRE>
 ars_web version $VERSION, Copyright (C) 1996 joel murphy
 ars_web comes with <A HREF="copying.html#nowarranty">ABSOLUTELY NO WARRANTY</A>
 This is free software, and you are welcome to redistribute it
 <A HREF="http:copying.html#conditions">under certain conditions</A>.

 </PRE>
</html>
EOF
    }
}

main();

exit 0;
