#!/usr/local/bin/perl
#
# $Header: /u1/project/ARSperl/ARSperl/RCS/Makefile.PL,v 1.4 1996/11/21 20:02:26 jcmurphy Exp $
#
# ARSperl Makefile
#
# INSTRUCTIONS:
#    Set the following below:
#       1) paths to API ($ARS_LDPATH and $INCLUDES)
#       2) libraries (uncomment/commentout appropriate $ARS_LIBS lines)
#       3) defines (see DEFINE OPTIONS)
#
#    run with "perl Makefile.PL" then type "make"
#
# $Log: Makefile.PL,v $
# Revision 1.4  1996/11/21 20:02:26  jcmurphy
# *** empty log message ***
#

use ExtUtils::MakeMaker;

# Set the paths to your ARS API directories..

$ARS_LDPATH = "-L/usr/ars/api/lib";
$INCLUDES = "-I/usr/ars/api/include";

# 3.0 libraries:

$ARS_LIBS = "-lar -lnsl -lnts";

# 2.x libraries:

#$ARS_LIBS = "-lar -lnsl -lnts -lntc";

WriteMakefile(
	      'NAME'	=> 'ARS',
	      'VERSION'	=> '1.44',
	      'LIBS'	=> ["${ARS_LDPATH} ${ARS_LIBS}"],

# DEFINE OPTIONS:
#
#    -DWASTE_MEM
#
#       If you want to free() allocated memory, don't define WASTE_MEM
#       In the past, there were some bad free() problems so we offered
#       this option.
#
#    -DPROFILE
#
#       Enable query profiling code (very little overhead).
#       See ars_GetProfileInfo() call for details.
#
#    -DARS20
#
#       If you are running ARS2.0.2 or anything less than 2.1, you should
#       add -DARS20 to the DEFINE line.
#
	      'DEFINE'	=> '-DPROFILE',
	      'OBJECT'  => "ARS.o",
	      'INC'	=> "${INCLUDES}",
#
# if you have trouble under solaris when linking (bfd assertion 
# failures) try uncommenting the following:
#
	      'LD' => "/usr/ccs/bin/ld",
);
