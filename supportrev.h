/*
$Header: /u1/project/ARSperl/ARSperl/RCS/supportrev.h,v 1.8 1998/12/28 15:46:10 jcmurphy Exp $

    ARSperl - An ARS v2 - v4 / Perl5 Integration Kit

    Copyright (C) 1995,1996,1997,1998,1999
	Joel Murphy, jmurphy@acsu.buffalo.edu
        Jeff Murphy, jcmurphy@acsu.buffalo.edu

    This program is free software; you can redistribute it and/or modify
    it under the terms as Perl itself. 
    
    Refer to the file called "Artistic" that accompanies the source distribution 
    of ARSperl (or the one that accompanies the source distribution of Perl
    itself) for a full description.
 
    Comments to:  arsperl@smurfland.cit.buffalo.edu
                  (this is a *mailing list* and you must be
                   a subscriber before posting)

    Comments to: arsperl@lurch.cit.buffalo.edu
    Home Page: http://arsinfo.cit.buffalo.edu

    LOG:

$Log: supportrev.h,v $
Revision 1.8  1998/12/28 15:46:10  jcmurphy
v1.62

Revision 1.7  1998/03/31 23:32:26  jcmurphy
NT patch by  Bill Middleton <wjm@metronet.com>

Revision 1.1  1998/03/17 15:19:02  aawimi
Initial revision

Revision 1.6  1997/10/20 21:00:41  jcmurphy
5203 beta. code cleanup. winnt additions. malloc/free
debugging code.

Revision 1.5  1997/10/07 14:29:49  jcmurphy
1.51

Revision 1.4  1997/10/06 13:39:48  jcmurphy
fix up some compilation warnings

Revision 1.3  1997/10/02 15:40:06  jcmurphy
1.50beta

Revision 1.2  1997/09/04 00:20:56  jcmurphy
*** empty log message ***

Revision 1.1  1997/08/05 21:21:24  jcmurphy
Initial revision


*/

#ifndef __supportrev_h_
#define __supportrev_h_

#include "support.h"

#undef EXTERN
#ifndef __supportrev_c_
# define EXTERN extern
#else
# define EXTERN 
#endif

EXTERN int  compmem(MEMCAST *m1, MEMCAST *m2, int size);
EXTERN int  copymem(MEMCAST *m1, MEMCAST *m2, int size);


EXTERN int strcpyHVal( HV *h, char *k, char *b, int len);
EXTERN int strmakHVal( HV *h, char *k, char **b);
EXTERN int intcpyHVal( HV *h, char *k, int *b);
EXTERN int uintcpyHVal( HV *h, char *k, unsigned int *b);
EXTERN int longcpyHVal( HV *h, char *k, long *b);
EXTERN int ulongcpyHVal( HV *h, char *k, unsigned long *b);
EXTERN int rev_ARDisplayList(ARControlStruct *ctrl, 
			     HV *h, char *k, ARDisplayList *d);
EXTERN int rev_ARDisplayStruct(ARControlStruct *ctrl, 
			       HV *h, ARDisplayStruct *d);
EXTERN int rev_ARInternalIdList(ARControlStruct *ctrl, 
				HV *h, char *k, ARInternalIdList *il);
EXTERN int rev_ARActiveLinkActionList(ARControlStruct *ctrl, HV *h, char *k, 
				      ARActiveLinkActionList *al);
EXTERN int rev_ARFieldAssignList(ARControlStruct *ctrl,
				 HV *h, char *k, ARFieldAssignList *m);
EXTERN int rev_ARAssignStruct(ARControlStruct *ctrl,
			      HV *h, char *k, ARAssignStruct *m);
EXTERN int rev_ARValueStruct(ARControlStruct *ctrl,
			     HV *h, char *k, char *t, ARValueStruct *m);
EXTERN int rev_ARAssignFieldStruct(ARControlStruct *ctrl,
				   HV *h, char *k, ARAssignFieldStruct *m);
EXTERN int rev_ARStatHistoryValue(ARControlStruct *ctrl,
				  HV *h, char *k, ARStatHistoryValue *s);
EXTERN int rev_ARArithOpAssignStruct(ARControlStruct *ctrl,
				     HV *h, char *k, ARArithOpAssignStruct *s);
EXTERN int rev_ARFunctionAssignStruct(ARControlStruct *ctrl,
				      HV *h, char *k,
				      ARFunctionAssignStruct *s);
EXTERN int rev_ARStatusStruct(ARControlStruct *ctrl,
			      HV *h, char *k, ARStatusStruct *m);
EXTERN int rev_ARFieldCharacteristics(ARControlStruct *ctrl,
				      HV *h, char *k, ARFieldCharacteristics *m);
EXTERN int rev_ARActiveLinkMacroStruct(ARControlStruct *ctrl,
				       HV *h, char *k, 
				       ARActiveLinkMacroStruct *m);
EXTERN int rev_ARMacroParmList(ARControlStruct *ctrl,
			       HV *h, char *k, ARMacroParmList *m);

#if AR_EXPORT_VERSION >= 3
EXTERN int rev_ARByteList(ARControlStruct *ctrl,
			  HV *h, char *k, ARByteList *b);
EXTERN int rev_ARCoordList(ARControlStruct *ctrl,
			   HV *h, char *k, ARCoordList *m);
EXTERN int rev_ARPropList(ARControlStruct *ctrl,
			  HV *h, char *k, ARPropList *m);
EXTERN int rev_ARAssignSQLStruct(ARControlStruct *ctrl,
				 HV *h, char *k, ARAssignSQLStruct *s);
#endif

#endif /* __supportrev_h_ */