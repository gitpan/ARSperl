#!/usr/local/bin/perl
#
# $Header: /u1/project/ARSperl/ARSperl/RCS/Makefile.PL,v 1.4 1996/11/21 20:02:26 jcmurphy Exp $
#
# ARSperl Makefile
#
# run me with "perl Makefile.PL" after tweaking things below
#
# $Log: Makefile.PL,v $
# Revision 1.4  1996/11/21 20:02:26  jcmurphy
# *** empty log message ***
#

use ExtUtils::MakeMaker;

$ARS_LDPATH = "-L/project/ar/api/lib";
$INCLUDES = "-I/project/ar/api/include";
$ARS_LIBS = "-lar -lnsl";

WriteMakefile(
	      'NAME'	=> 'ARS',
	      'VERSION'	=> '1.32',
	      'LIBS'	=> ["${ARS_LDPATH} ${ARS_LIBS}"],
#
# If you want to free() allocated memory, don't define WASTE_MEM
# In the past, there were some bad free() problems so we offered
# this option.
#
# If you are running ARS2.0.2 or anything less than 2.1, you should
# add -DARS20 to the DEFINE line.
#
#	      'DEFINE'	=> '-g -DPROFILE -DWASTE_MEM',
	      'DEFINE'	=> '-DPROFILE',
	      'OBJECT'  => "ARS.o",
	      'INC'	=> "${INCLUDES}",
#
# if you have trouble under solaris when linking (bfd assertion 
# failures) try uncommenting the following:
#
#	      'LD' => "/usr/ccs/bin/ld",
);
