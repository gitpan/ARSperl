/*
$Header: /u1/project/ARSperl/ARSperl/RCS/ARS.xs,v 1.34 1997/10/06 13:39:02 jcmurphy Exp $

    ARSperl - An ARS2.x-3.0 / Perl5.x Integration Kit

    Copyright (C) 1995,1996,1997 
	Joel Murphy, jmurphy@acsu.buffalo.edu
        Jeff Murphy, jcmurphy@acsu.buffalo.edu
 
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
 
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

    Comments to:  arsperl@smurfland.cit.buffalo.edu
                  (this is a *mailing list*)

    Bugs to: arsperl-bugs@smurfland.cit.buffalo.edu
 
    LOG:

$Log: ARS.xs,v $
Revision 1.34  1997/10/06 13:39:02  jcmurphy
fix up some compilation warnings

Revision 1.33  1997/10/02 15:39:31  jcmurphy
1.50beta

Revision 1.32  1997/09/04 00:21:03  jcmurphy
*** empty log message ***

Revision 1.31  1997/08/05 21:20:24  jcmurphy
1.50 dev1

Revision 1.30  1997/07/02 15:52:18  jcmurphy
altered error handling routines. remove err buffer and ars_errstr
pointer from code.

Revision 1.29  1997/05/22 15:23:04  jmurphy
duh

Revision 1.28  1997/05/22 14:40:05  jmurphy
changed logic for checking for scalar values

Revision 1.27  1997/03/25 19:20:06  jmurphy
fixed ars_GetListSchema

Revision 1.26  1997/02/20 20:27:47  jcmurphy
added some minor code to handle decoding TR. and DB. values in qualifications

Revision 1.25  1997/02/19 22:39:28  jcmurphy
fixed problem with bad free() in ars_Login

Revision 1.24  1997/02/19 21:55:38  jmurphy
fixed bug in perl_ARValueStruct

Revision 1.23  1997/02/19 20:24:41  jcmurphy
*** empty log message ***

Revision 1.22  1997/02/19 15:30:25  jcmurphy
fixed bad goto

Revision 1.21  1997/02/19 14:21:48  jcmurphy
oops. fixed double call to getlistserver in ars_Login

Revision 1.20  1997/02/18 18:45:54  jcmurphy
ran thru -Wall and cleaned up some blunders and stuff

Revision 1.19  1997/02/18 16:37:32  jmurphy
a couple fixes.  added destructors for control struct, qualifier struct

Revision 1.18  1997/02/17 16:53:35  jcmurphy
commented ARTermination back out for a little bit longer.

Revision 1.17  1997/02/17 16:21:12  jcmurphy
uncommented ARTermintation(), added GetListServer to ars_Login incase
no server is specified. added ars_GetCurrentServer so you can determine
what server you connected to (if you didnt specify one).

Revision 1.16  1997/02/14 20:48:06  jcmurphy
un-commented the ARInitialization() call. this allows
you to write a perl script that connects to a private
server.

Revision 1.15  1997/02/14 20:38:49  jcmurphy
fixed phantom function call. initialized some un-inited stuff

Revision 1.14  1997/02/13 15:21:06  jcmurphy
modified comments


*/

#include "support.h"
#include "supportrev.h"

#if AR_EXPORT_VERSION < 3
#define AR_LIST_SCHEMA_ALL 1 
#endif

MODULE = ARS		PACKAGE = ARS		PREFIX = ARS

PROTOTYPES: ENABLE

int
isa_int(...)
	CODE:
	{
	  if (items != 1)
	    croak("usage: isa_int(value)");
	  RETVAL = SvIOKp(ST(0));
	}
	OUTPUT:
	RETVAL

int
isa_float(...)
	CODE:
	{
	  if (items != 1)
	    croak("usage: isa_int(value)");
	  RETVAL = SvNOKp(ST(0));
	}
	OUTPUT:
	RETVAL

int
isa_string(...)
	CODE:
	{
	  if (items != 1)
	    croak("usage: isa_int(value)");
	  RETVAL = SvPOKp(ST(0));
	}
	OUTPUT:
	RETVAL

HV *
ars_perl_qualifier(in)
	ARQualifierStruct *	in
	CODE:
	{
	  RETVAL = perl_qualifier(in);
	}
	OUTPUT:
	RETVAL

ARQualifierStruct *
ars_LoadQualifier(ctrl,schema,qualstring,displayTag=NULL)
	ARControlStruct *	ctrl
	char *			schema
	char *			qualstring
	char *			displayTag
	CODE:
	{
	  int ret;
	  ARStatusList status;
	  ARQualifierStruct *qual = MALLOCNN(sizeof(ARQualifierStruct));
	  
	  (void) ARError_reset();
	  /* this gets freed below in the ARQualifierStructPTR package */
	  ret = ARLoadARQualifierStruct(ctrl, schema, displayTag, qualstring, qual, &status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if (! ARError(ret, status)) {
	    RETVAL = qual;
	  } else {
	    RETVAL = NULL;
#ifndef WASTE_MEM
	    free(qual);
#endif
	  }
	}
	OUTPUT:
	RETVAL

void
__ars_Termination()
	CODE:
	{
	  int ret;
	  ARStatusList status;
	  
	  (void) ARError_reset();
	  ret = ARTermination(&status);
	  if (ARError(ret, status)) {
	    warn("failed in ARTermination\n");
	  }
	}

void
__ars_init()
	CODE:
	{
	  int ret;
	  ARStatusList status;
	
	  (void) ARError_reset();
	  ret = ARInitialization(&status);
	  if (ARError(ret, status)) {
	    croak("unable to initialize ARS module");
	  }
	}

ARControlStruct *
ars_Login(server,username,password)
	char *		server
	char *		username
	char *		password
	CODE:
	{
	  int ret, s_ok = 1;
	  ARStatusList status;
	  ARServerNameList serverList;
	  ARControlStruct *ctrl;
#ifdef PROFILE
	  struct timeval tv;
#endif

	  RETVAL = NULL;
	  (void) ARError_reset();  
	  /* this gets freed below in the ARControlStructPTR package */
	  ctrl = (ARControlStruct *)MALLOCNN(sizeof(ars_ctrl));
	  ((ars_ctrl *)ctrl)->queries = 0;
	  ((ars_ctrl *)ctrl)->startTime = 0;
	  ((ars_ctrl *)ctrl)->endTime = 0;
#ifdef PROFILE
	  if (gettimeofday(&tv, 0) != -1)
		((ars_ctrl *)ctrl)->startTime = tv.tv_sec;
	  else
		perror("gettimeofday");
#endif
	  ctrl->cacheId = 0;
	  ctrl->operationTime = 0;
	  strncpy(ctrl->user, username, sizeof(ctrl->user));
	  ctrl->user[sizeof(ctrl->user)-1] = 0;
	  strncpy(ctrl->password, password, sizeof(ctrl->password));
	  ctrl->password[sizeof(ctrl->password)-1] = 0;
	  ctrl->language[0] = 0;
	  if (!server || !*server) {
	    ret = ARGetListServer(&serverList, &status);
	    if (ARError(ret, status)) {
	      free(ctrl);
	      goto ar_login_end;
	    }
	    if (serverList.numItems == 0) {
	      (void) ARError_add(AR_RETURN_ERROR, AP_ERR_NO_SERVERS);
	      free(ctrl);
	      goto ar_login_end;
	    }
	    server = serverList.nameList[0];
	    s_ok = 0;
	  }
	  strncpy(ctrl->server, server, sizeof(ctrl->server));
	  ctrl->server[sizeof(ctrl->server)-1] = 0;
	  /* finally, check to see if the user id is valid */
	  ret = ARVerifyUser(ctrl, NULL, NULL, NULL, &status);
	  if(ARError(ret, status))
		free(ctrl); /* invalid, cleanup */
	  else
	  	RETVAL = ctrl; /* valid, return ctrl struct */
#ifndef WASTE_MEM
	  if(s_ok == 0)
	  	FreeARServerNameList(&serverList,FALSE);
#endif
	ar_login_end:;
	}
	OUTPUT:
	RETVAL

SV *
ars_GetCurrentServer(ctrl)
	ARControlStruct *	ctrl
	CODE:
	{
	  RETVAL = NULL;
	  (void) ARError_reset();
	  if(ctrl && ctrl->server) {
	    RETVAL = newSVpv(ctrl->server, strlen(ctrl->server));
	  } 
	}
	OUTPUT:
	RETVAL

HV *
ars_GetProfileInfo(ctrl)
	ARControlStruct *	ctrl
	CODE:
	{
	  RETVAL = newHV();
	  (void) ARError_reset();
#ifdef PROFILE
	  hv_store(RETVAL, "queries", strlen("queries"),
	  	   newSViv(((ars_ctrl *)ctrl)->queries), 0);
	  hv_store(RETVAL, "startTime", strlen("startTime"),
		   newSViv(((ars_ctrl *)ctrl)->startTime), 0);
#else /* profiling not compiled in */
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_OPT_NA, "Optional profiling code not compiled into this build of ARSperl");
#endif
	}
	OUTPUT:
	RETVAL

void
ars_Logoff(ctrl)
	ARControlStruct *	ctrl
	CODE:
	{
	    int          ret;
	    ARStatusList status;
	    (void) ARError_reset();
	    if (!ctrl) return;
	    ret = ARTermination(&status);
	    (void) ARError(ret, status);
	}

void
ars_GetListField(control,schema,changedsince=0,fieldType=ULONG_MAX)
	ARControlStruct *	control
	char *			schema
	unsigned long		changedsince
	unsigned long		fieldType
	PPCODE:
	{
	  ARInternalIdList idlist;
	  ARStatusList status;
	  int ret, i;
	  (void) ARError_reset();
#if AR_EXPORT_VERSION >= 3
	  if (fieldType == ULONG_MAX)
	    fieldType = AR_FIELD_TYPE_ALL;
	  
	  ret = ARGetListField(control,schema,fieldType,changedsince,&idlist,&status);
#else
	  ret = ARGetListField(control,schema,changedsince,&idlist,&status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)control)->queries++;
#endif
	  if (!ARError(ret,status)) {
	    for (i=0; i<idlist.numItems; i++)
	      XPUSHs(sv_2mortal(newSViv(idlist.internalIdList[i])));
#ifndef WASTE_MEM
	    FreeARInternalIdList(&idlist,FALSE);
#endif
	  }
	}

void
ars_GetFieldByName(control,schema,field_name)
	ARControlStruct *	control
	char *			schema
	char *			field_name
	PPCODE:
	{
	  int ret, loop;
	  ARInternalIdList idList;
	  ARStatusList status;
#if AR_EXPORT_VERSION >= 3
	  ARNameType fieldName;
#else
	  ARDisplayList displayList;
#endif
	  (void) ARError_reset();
#if AR_EXPORT_VERSION >= 3
	  ret = ARGetListField(control, schema, AR_FIELD_TYPE_ALL, (ARTimestamp)0, &idList, &status);
#else
	  ret = ARGetListField(control, schema, (ARTimestamp)0, &idList, &status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)control)->queries++;
#endif
	  if (! ARError(ret, status)) {
	    for (loop=0; loop<idList.numItems; loop++) {
#if AR_EXPORT_VERSION >= 3
	      ret = ARGetFieldCached(control, schema, idList.internalIdList[loop], fieldName, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &status);
#else
	      ret = ARGetFieldCached(control, schema, idList.internalIdList[loop], NULL, NULL, NULL, NULL, NULL, NULL, &displayList, NULL, NULL, NULL, NULL, NULL, &status);
#endif
	      if (ARError(ret, status))
	        break;
#if AR_EXPORT_VERSION >= 3
	      if (strcmp(field_name, fieldName) == 0)
#else 
	      if (displayList.numItems < 1) {
		(void) ARError_add(ARSPERL_TRACEBACK, 1, "No fields were returned in display list");
		break;
	      }
	      if (strcmp(field_name,displayList.displayList[0].label)==0)
#endif
	      {
		XPUSHs(sv_2mortal(newSViv(idList.internalIdList[loop])));
#if AR_EXPORT_VERSION < 3
#ifndef WASTE_MEM
		FreeARDisplayList(&displayList, FALSE);
#endif
#endif
		break;
	      }
#if AR_EXPORT_VERSION < 3
#ifndef WASTE_MEM
	      FreeARDisplayList(&displayList, FALSE);
#endif
#endif
	    }
#ifndef WASTE_MEM
	    FreeARInternalIdList(&idList, FALSE);
#endif
	  }
	}

void
ars_GetFieldTable(control,schema)
	ARControlStruct *	control
	char *			schema
	PPCODE:
	{
	  int ret, loop;
	  ARInternalIdList idList;
	  ARStatusList status;
#if AR_EXPORT_VERSION >= 3
	  ARNameType fieldName;
#else
	  ARDisplayList displayList;
#endif
	  (void) ARError_reset();
#if AR_EXPORT_VERSION >= 3
	  ret = ARGetListField(control, schema, AR_FIELD_TYPE_ALL, (ARTimestamp)0, &idList, &status);
#else
	  ret = ARGetListField(control, schema, (ARTimestamp)0, &idList, &status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)control)->queries++;
#endif
	  if (! ARError(ret, status)) {
	    for (loop=0; loop<idList.numItems; loop++) {
#if AR_EXPORT_VERSION >= 3
	      ret = ARGetFieldCached(control, schema, idList.internalIdList[loop], fieldName, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &status);
#else
	      ret = ARGetFieldCached(control, schema, idList.internalIdList[loop], NULL, NULL, NULL, NULL, NULL, NULL, &displayList, NULL, NULL, NULL, NULL, NULL, &status);
#endif
	      if (ARError(ret, status))
	        break;
#if AR_EXPORT_VERSION >= 3
	      XPUSHs(sv_2mortal(newSVpv(fieldName, 0)));
#else
	      if (displayList.numItems < 1) {
		(void) ARError_add(ARSPERL_TRACEBACK, 1, "No fields were returned in display list");
		continue;
	      }
	      XPUSHs(sv_2mortal(newSVpv(displayList.displayList[0].label, strlen(displayList.displayList[0].label))));
#endif
	      XPUSHs(sv_2mortal(newSViv(idList.internalIdList[loop])));
#if AR_EXPORT_VERSION < 3
#ifndef WASTE_MEM
	      FreeARDisplayList(&displayList, FALSE);
#endif
#endif
	    }
#ifndef WASTE_MEM
	    FreeARInternalIdList(&idList, FALSE);
#endif
	  }
	}

char *
ars_CreateEntry(ctrl,schema...)
	ARControlStruct *	ctrl
	char *			schema
	CODE:
	{
	  int a, i, c = (items - 2) / 2, j;
	  AREntryIdType entryId;
	  ARFieldValueList fieldList;
	  ARStatusList      status;
	  int               ret;
	  unsigned int dataType;
	  
	  RETVAL = "";
	  (void) ARError_reset();
	  if (((items - 2) % 2) || c < 1) {
	    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  } else {
	    fieldList.numItems = c;
	    fieldList.fieldValueList = MALLOCNN(sizeof(ARFieldValueStruct)*c);
	    for (i=0; i<c; i++) {
	      a = i*2+2;
	      fieldList.fieldValueList[i].fieldId = SvIV(ST(a));
#if AR_EXPORT_VERSION >= 3
	      ret = ARGetFieldCached(ctrl, schema, fieldList.fieldValueList[i].fieldId, NULL, NULL, &dataType, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &status);
#else
	      ret = ARGetFieldCached(ctrl, schema, fieldList.fieldValueList[i].fieldId, &dataType, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &status);
#endif
	      if (ARError(ret, status)) {	
		goto create_entry_end;
	      }
	      if (sv_to_ARValue(ST(a+1), dataType, &fieldList.fieldValueList[i].value) < 0) {
#ifndef WASTE_MEM
		for (j=0; j<i; j++) {
		  FreeARValueStruct(&fieldList.fieldValueList[j].value, FALSE);
		}
#endif
		goto create_entry_end;
	      }
	    }
	    ret = ARCreateEntry(ctrl, schema, &fieldList, entryId, &status);
#ifdef PROFILE
	    ((ars_ctrl *)ctrl)->queries++;
#endif
	    if (! ARError(ret, status)) {
	      RETVAL = entryId;
	    }
#ifndef WASTE_MEM
	    for (j=0; j<c; j++) {
	      FreeARValueStruct(&fieldList.fieldValueList[j].value, FALSE);
	    }
#endif
	  create_entry_end:;
#ifndef WASTE_MEM
	    free(fieldList.fieldValueList);
#endif
	  }
	}
	OUTPUT:
	RETVAL

int
ars_DeleteEntry(ctrl,schema,entry_id)
	ARControlStruct *	ctrl
	char *			schema
	char *			entry_id
	CODE:
	{
	  int            ret;
	  ARStatusList   status;
#if AR_EXPORT_VERSION >= 3
	  SV           **fetch_entry;
	  AREntryIdList  entryList;
	  AV            *input_list;
	  int            i;

	  RETVAL = -1; /* assume error */
	  (void) ARError_reset();
	  if(perl_BuildEntryList(&entryList, entry_id) != 0)
		goto delete_fail;
	  ret = ARDeleteEntry(ctrl, schema, &entryList, 0, &status);
#ifndef WASTE_MEM
	  FreeAREntryIdList(&entryList, FALSE);
#endif
#else /* ARS 2 */
	  RETVAL = -1; /* assume error */
	  if(!entry_id || !*entry_id) {
		ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_EID);
		goto delete_fail;
	  }
	  ret = ARDeleteEntry(ctrl, schema, entry_id, &status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if (ARError(ret, status))
	    RETVAL=-1;
	  else
	    RETVAL=0;
	delete_fail:;
	}
	OUTPUT:
	RETVAL

void
ars_GetEntry(ctrl,schema,entry_id,...)
	ARControlStruct *	ctrl
	char *			schema
	char *			entry_id
	PPCODE:
	{
	  int               c = items - 3, i, ret;
	  ARInternalIdList  idList;
	  ARFieldValueList  fieldList;
	  ARStatusList      status;
	  char             *entryId;
#if AR_EXPORT_VERSION >= 3
	  SV              **fetch_entry;
	  AREntryIdList     entryList;
	  AV               *input_list;
#endif

	  (void) ARError_reset();
	  if (c < 1) {
	    idList.numItems = 0; /* get all fields */
	  } else {
	    idList.numItems = c;
	    idList.internalIdList = MALLOCNN(sizeof(ARInternalId) * c);
	    if (!idList.internalIdList)
	      goto get_entry_end;
	    for (i=0; i<c; i++)
	      idList.internalIdList[i] = SvIV(ST(i+3));
	  }
#if AR_EXPORT_VERSION >= 3
	  /* build entryList */
	  if(perl_BuildEntryList(&entryList, entry_id) != 0)
		goto get_entry_end;

	  ret = ARGetEntry(ctrl, schema, &entryList, &idList, &fieldList, &status);
#ifndef WASTE_MEM
	  free(entryList.entryIdList);
#endif
#else /* ARS 2 */
	  if(!entry_id || !*entry_id) {
		ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_EID);
		goto get_entry_cleanup;
	  }
	  ret = ARGetEntry(ctrl, schema, entry_id, &idList, &fieldList, &status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if (ARError(ret, status)) {
	    goto get_entry_cleanup;
	  }
	  
	  if(fieldList.numItems < 1) {
	    goto get_entry_cleanup;
 	  }
	  for (i=0; i<fieldList.numItems; i++) {
	    XPUSHs(newSViv(fieldList.fieldValueList[i].fieldId));
	    XPUSHs(perl_ARValueStruct(&fieldList.fieldValueList[i].value));
	  }
#ifndef WASTE_MEM
	  FreeARFieldValueList(&fieldList,FALSE);
#endif
	get_entry_cleanup:;
#ifndef WASTE_MEM
	  FreeARInternalIdList(&idList, FALSE);
#endif
	get_entry_end:;
	}

void
ars_GetListEntry(ctrl,schema,qualifier,maxRetrieve,...)
	ARControlStruct *	ctrl
	char *			schema
	ARQualifierStruct *	qualifier
	int			maxRetrieve
	PPCODE:
	{
	  int c = (items - 4) / 2, i;
	  int field_off = 4;
	  ARSortList sortList;
	  AREntryListList entryList;
	  unsigned int num_matches;
	  ARStatusList status;
	  int ret;
#if AR_EXPORT_VERSION >= 3
	  AREntryListFieldList getListFields, *getList = NULL;
	  AV *getListFields_array;

	  (void) ARError_reset();	  
	  if ((items - 4) % 2) {
	    /* odd number of arguments, so argument after maxRetrieve is
	       optional getListFields (an array of hash refs) */
	    if (SvROK(ST(field_off)) &&
		(getListFields_array = (AV *)SvRV(ST(field_off))) &&
		SvTYPE(getListFields_array) == SVt_PVAV) {
	      getList = &getListFields;
	      getListFields.numItems = av_len(getListFields_array) + 1;
	      getListFields.fieldsList = MALLOCNN(sizeof(AREntryListFieldStruct) * getListFields.numItems);
	      /* set query field list */
	      for (i=0; i<getListFields.numItems; i++) {
		SV **array_entry, **hash_entry;
		HV *field_hash;
		/* get hash from array */
		if ((array_entry = av_fetch(getListFields_array, i, 0)) &&
		    SvROK(*array_entry) &&
		    SvTYPE(field_hash = (HV*)SvRV(*array_entry)) == SVt_PVHV) {
		  /* get fieldId, columnWidth and separator from hash */
		  if (! (hash_entry = hv_fetch(field_hash, "fieldId", 7, 0))) {
		    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_LFLDS);
#ifndef WASTE_MEM
		    free(getListFields.fieldsList);
#endif
		    goto getlistentry_end;
		  }
		  getListFields.fieldsList[i].fieldId = SvIV(*hash_entry);
		  /* printf("field_id: %i\n", getListFields.fieldsList[i].fieldId); */ /* DEBUG */
		  if (! (hash_entry = hv_fetch(field_hash, "columnWidth", 11, 0))) {
		    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_LFLDS);
#ifndef WASTE_MEM
		    free(getListFields.fieldsList);
#endif
		    goto getlistentry_end;
		  }
		  getListFields.fieldsList[i].columnWidth = SvIV(*hash_entry);
		  if (! (hash_entry = hv_fetch(field_hash, "separator", 9, 0))) {
		    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_LFLDS);
#ifndef WASTE_MEM
		    free(getListFields.fieldsList);
#endif
		    goto getlistentry_end;
		  }
		  strncpy(getListFields.fieldsList[i].separator,
			  SvPV(*hash_entry, na),
			  sizeof(getListFields.fieldsList[i].separator));
		}
	      }
	    } else {
	      (void) ARError_add(AR_RETURN_ERROR, AP_ERR_LFLDS_TYPE);
	      goto getlistentry_end;
	    }
	    /* increase the offset of the first sortList field by one */
	    field_off ++;
	  }
#else  /* ARS 2 */
	  if ((items - 4) % 2) {
	    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	    goto getlistentry_end;
	  }
#endif /* if ARS >= 3 */
	  /* build sortList */
	  sortList.numItems = c;
	  sortList.sortList = MALLOCNN(sizeof(ARSortStruct)*c);
	  for (i=0; i<c; i++) {
	    sortList.sortList[i].fieldId = SvIV(ST(i*2+field_off));
	    sortList.sortList[i].sortOrder = SvIV(ST(i*2+field_off+1));
	  }
#if AR_EXPORT_VERSION >= 3
	  ret = ARGetListEntry(ctrl, schema, qualifier, getList, &sortList, maxRetrieve, &entryList, &num_matches, &status);
#else
	  ret = ARGetListEntry(ctrl, schema, qualifier, &sortList, maxRetrieve, &entryList, &num_matches, &status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if (ARError(ret, status)) {
#ifndef WASTE_MEM
	    FreeARSortList(&sortList,FALSE);
#endif
	    goto getlistentry_end;
	  }
	  for (i=0; i<entryList.numItems; i++) {
#if AR_EXPORT_VERSION >= 3
	    AV *entryIdList;
	    
	    if (entryList.entryList[i].entryId.numItems == 1) {
	      /* only one entryId -- so just return its value to be compatible
		 with ars 2 */
	      XPUSHs(sv_2mortal(newSVpv(entryList.entryList[i].entryId.entryIdList[0], 0)));
	    } else {
	      /* more than one entry -- this must be a join schema. merge
	       * the list into a single entry-id to keep things
	       * consistent.
               */
	      int   entry;
	      char *joinId = (char *)NULL;
	      char  joinSep[2] = {AR_ENTRY_ID_SEPARATOR, 0};

	      for (entry=0; entry<entryList.entryList[i].entryId.numItems; entry++) {
	        joinId = strappend(joinId, entryList.entryList[i].entryId.entryIdList[entry]);
	        if(entry < entryList.entryList[i].entryId.numItems-1)
		    joinId = strappend(joinId, joinSep);
	      }
	      XPUSHs(sv_2mortal(newSVpv(joinId, 0)));
	    }
#else /* ARS 2 */
	    XPUSHs(sv_2mortal(newSVpv(entryList.entryList[i].entryId, 0)));
#endif
	    XPUSHs(sv_2mortal(newSVpv(entryList.entryList[i].shortDesc, 0)));
	  }
#ifndef WASTE_MEM
	  FreeAREntryListList(&entryList,FALSE);
#endif
	  getlistentry_end:;
	}

void
ars_GetListSchema(ctrl,changedsince=0,schemaType=AR_LIST_SCHEMA_ALL,name=NULL)
	ARControlStruct *	ctrl
	unsigned int		changedsince
	unsigned int		schemaType
	char *			name
	PPCODE:
	{
	  ARNameList nameList;
	  ARStatusList status;
	  int i, ret;

	  (void) ARError_reset();	  
#if AR_EXPORT_VERSION >= 3
	  ret = ARGetListSchema(ctrl, changedsince, schemaType, name, 
				&nameList, &status);
#else
	  ret = ARGetListSchema(ctrl, changedsince, 
				&nameList, &status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if (! ARError(ret, status)) {
	    for (i=0; i<nameList.numItems; i++) {
	      XPUSHs(sv_2mortal(newSVpv(nameList.nameList[i], 0)));
	    }
#ifndef WASTE_MEM
	    FreeARNameList(&nameList,FALSE);
#endif
	  }
	}

void
ars_GetListServer()
	PPCODE:
	{
	  ARServerNameList serverList;
	  ARStatusList status;
	  int i, ret;

	  (void) ARError_reset();	  
	  ret = ARGetListServer(&serverList, &status);
	  if (! ARError(ret, status)) {
	    for (i=0; i<serverList.numItems; i++) {
	      XPUSHs(sv_2mortal(newSVpv(serverList.nameList[i], 0)));
	    }
#ifndef WASTE_MEM
	    FreeARServerNameList(&serverList,FALSE);
#endif
	  }
	}

HV *
ars_GetActiveLink(ctrl,name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  int ret;
	  unsigned int order;
	  ARNameType schema;
	  ARInternalIdList groupList;
	  unsigned int executeMask;
#if AR_EXPORT_VERSION >= 3
	  ARInternalId controlField;
	  ARInternalId focusField;
#else	  
	  ARInternalId field;
	  ARDisplayList displayList;
#endif
	  unsigned int enable;
	  ARActiveLinkActionList actionList;
#if  AR_EXPORT_VERSION >= 3
	  ARActiveLinkActionList elseList;
#endif
	  char *helpText;
	  ARTimestamp timestamp;
	  ARNameType owner;
	  ARNameType lastChanged;
	  char *changeDiary;
	  ARStatusList status;
	  SV *ref;
	  ARQualifierStruct *query=MALLOCNN(sizeof(ARQualifierStruct));

	  (void) ARError_reset();
#if  AR_EXPORT_VERSION >= 3
	  ret = ARGetActiveLink(ctrl,name,&order,schema,&groupList,&executeMask,&controlField,&focusField,&enable,query,&actionList,&elseList,&helpText,&timestamp,owner,lastChanged,&changeDiary,&status);
#else
	  ret = ARGetActiveLink(ctrl,name,&order,schema,&groupList,&executeMask,&field,&displayList,&enable,query,&actionList,&helpText,&timestamp,owner,lastChanged,&changeDiary,&status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  RETVAL = newHV();
	  if (!ARError(ret,status)) {
	    /* store name of active link */
	    hv_store(RETVAL, "name", strlen("name"),
		     newSVpv(name, 0), 0);
	    hv_store(RETVAL, "order", strlen("order"),
		     newSViv(order),0);
	    hv_store(RETVAL, "schema", strlen("schema"),
		     newSVpv(schema,0),0);
	    hv_store(RETVAL, "groupList", strlen("groupList"),
		     perl_ARList((ARList *)&groupList,
				 (ARS_fn)perl_ARInternalId,
				 sizeof(ARInternalId)), 0);
	    hv_store(RETVAL, "executeMask", strlen("executeMask"),
		     newSViv(executeMask),0);
#if  AR_EXPORT_VERSION >= 3
	    hv_store(RETVAL, "focusField", strlen("focusField"),
		     newSViv(focusField), 0);
	    hv_store(RETVAL, "controlField", strlen("controlField"),
		     newSViv(controlField), 0);
#else
	    hv_store(RETVAL, "field", strlen("field"),
		     newSViv(field), 0);
	    hv_store(RETVAL, "displayList", strlen("displayList"),
		     perl_ARList((ARList *)&displayList,
				 (ARS_fn)perl_ARDisplayStruct,
				 sizeof(ARDisplayStruct)), 0);
#endif
	    hv_store(RETVAL, "enable", strlen("enable"),
		     newSViv(enable), 0);
	    /* a bit of a hack -- makes blessed reference to qualifier */
	    ref = newSViv(0);
	    sv_setref_pv(ref, "ARQualifierStructPtr", (void*)query);
	    hv_store(RETVAL, "query", strlen("query"),
		     ref, 0);
	    hv_store(RETVAL, "actionList", strlen("actionList"),
		     perl_ARList((ARList *)&actionList,
				 (ARS_fn)perl_ARActiveLinkActionStruct,
				 sizeof(ARActiveLinkActionStruct)), 0);
#if  AR_EXPORT_VERSION >= 3
	    hv_store(RETVAL, "elseList", strlen("elseList"),
		     perl_ARList((ARList *)&elseList,
				 (ARS_fn)perl_ARActiveLinkActionStruct,
				 sizeof(ARActiveLinkActionStruct)), 0);
#endif
	    if (helpText)
	      hv_store(RETVAL, "helpText", strlen("helpText"),
		       newSVpv(helpText,0), 0);
	    hv_store(RETVAL, "timestamp", strlen("timestamp"),
		     newSViv(timestamp), 0);
	    hv_store(RETVAL, "owner", strlen("owner"),
		     newSVpv(owner,0), 0);
	    hv_store(RETVAL, "lastChanged", strlen("lastChanged"),
		     newSVpv(lastChanged,0), 0);
	    if (changeDiary)
	      hv_store(RETVAL, "changeDiary", strlen("changeDiary"),
		       newSVpv(changeDiary,0), 0);
#ifndef WASTE_MEM
	    FreeARInternalIdList(&groupList,FALSE);
#if  AR_EXPORT_VERSION < 3
	    FreeARDisplayList(&displayList,FALSE);
#endif
	    FreeARActiveLinkActionList(&actionList,FALSE);
#if  AR_EXPORT_VERSION >= 3
	    FreeARActiveLinkActionList(&elseList,FALSE);
#endif
	    if(helpText)
	      free(helpText);
	    if(changeDiary)
	      free(changeDiary);
#endif
	  }
	}
	OUTPUT:
	RETVAL

HV *
ars_GetFilter(ctrl,name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  int ret;
	  unsigned int order;
	  unsigned int opSet;
	  ARNameType schema;
	  unsigned int enable;
	  char *helpText;
	  char *changeDiary;
	  ARFilterActionList actionList;
#if  AR_EXPORT_VERSION >= 3
	  ARFilterActionList elseList;
#endif
	  ARTimestamp timestamp;
	  ARNameType owner;
	  ARNameType lastChanged;
	  ARStatusList status;
	  SV *ref;
	  ARQualifierStruct *query=MALLOCNN(sizeof(ARQualifierStruct));

	  (void) ARError_reset();
#if AR_EXPORT_VERSION >= 3
	  ret = ARGetFilter(ctrl, name, &order, schema, &opSet, &enable, 
			    query, &actionList, &elseList, &helpText,
			    &timestamp, owner, lastChanged, &changeDiary,
			    &status);
#else
	  ret = ARGetFilter(ctrl, name, &order, schema, &opSet, &enable, 
			    query, &actionList, &helpText, &timestamp, 
			    owner, lastChanged, &changeDiary, &status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  RETVAL = newHV();
	  if (!ARError(ret,status)) {
	    hv_store(RETVAL, "name", strlen("name"),
		     newSVpv(name, 0), 0);
	    hv_store(RETVAL, "order", strlen("order"),
		     newSViv(order), 0);
	    hv_store(RETVAL, "schema", strlen("schema"),
		     newSVpv(schema, 0), 0);
	    hv_store(RETVAL, "opSet", strlen("opSet"),
		     newSViv(opSet), 0);
	    hv_store(RETVAL, "enable", strlen("enable"),
		     newSViv(enable), 0);
	    /* a bit of a hack -- makes blessed reference to qualifier */
	    ref = newSViv(0);
	    sv_setref_pv(ref, "ARQualifierStructPtr", (void *)query);
	    hv_store(RETVAL, "query", strlen("query"), ref, 0);
	    hv_store(RETVAL, "actionList", strlen("actionList"),
		     perl_ARList((ARList *)&actionList,
				 (ARS_fn)perl_ARFilterActionStruct,
				 sizeof(ARFilterActionStruct)), 0);
#if AR_EXPORT_VERSION >= 3
	    hv_store(RETVAL, "elseList", strlen("elseList"),
		     perl_ARList((ARList *)&elseList,
				 (ARS_fn)perl_ARFilterActionStruct,
				 sizeof(ARFilterActionStruct)), 0);
#endif
	    if(helpText)
		hv_store(RETVAL, "helpText", strlen("helpText"),
			 newSVpv(helpText, 0), 0);
	    hv_store(RETVAL, "timestamp", strlen("timestamp"),
		     newSViv(timestamp), 0);
	    hv_store(RETVAL, "owner", strlen("owner"),
		     newSVpv(owner, 0), 0);
	    hv_store(RETVAL, "lastChanged", strlen("lastChanged"),
		     newSVpv(lastChanged, 0), 0);
	    if(changeDiary) 
		hv_store(RETVAL, "changeDiary", strlen("changeDiary"),
			newSVpv(changeDiary, 0), 0);
#ifndef WASTE_MEM
	    FreeARFilterActionList(&actionList,FALSE);
#if AR_EXPORT_VERSION >= 3
	    FreeARFilterActionList(&elseList,FALSE);
#endif
	    if(helpText)
	      free(helpText);
	    if(changeDiary)
	      free(changeDiary);
#endif
	  }
	}
	OUTPUT:
	RETVAL

void
ars_GetServerStatistics(ctrl,...)
	ARControlStruct *	ctrl
	PPCODE:
	{
	  ARServerInfoRequestList requestList;
	  ARServerInfoList serverInfo;
	  int i, ret;
	  ARStatusList status;

	  (void) ARError_reset();
	  if(items < 1) {
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  } else {
		requestList.numItems = items - 1;
		requestList.requestList = MALLOCNN(sizeof(unsigned int) * (items-1));
		if(requestList.requestList) {
			for(i=1; i<items; i++) {
				requestList.requestList[i-1] = SvIV(ST(i));
			}
			ret = ARGetServerStatistics(ctrl, &requestList, &serverInfo, &status);
#ifdef PROFILE
			((ars_ctrl *)ctrl)->queries++;
#endif
			if(ARError(ret, status)) {
#ifndef WASTE_MEM
				free(requestList.requestList);
#endif
			} else {
				for(i=0; i<serverInfo.numItems; i++) {
					XPUSHs(sv_2mortal(newSViv(serverInfo.serverInfoList[i].operation)));
					switch(serverInfo.serverInfoList[i].value.dataType) {
					case AR_DATA_TYPE_ENUM:
					case AR_DATA_TYPE_TIME:
					case AR_DATA_TYPE_BITMASK:
					case AR_DATA_TYPE_INTEGER:
						XPUSHs(sv_2mortal(newSViv(serverInfo.serverInfoList[i].value.u.intVal)));
						break;
					case AR_DATA_TYPE_REAL:
						XPUSHs(sv_2mortal(newSVnv(serverInfo.serverInfoList[i].value.u.realVal)));
						break;
					case AR_DATA_TYPE_CHAR:
						XPUSHs(sv_2mortal(newSVpv(serverInfo.serverInfoList[i].value.u.charVal,
							strlen(serverInfo.serverInfoList[i].value.u.charVal))));
						break;
					}
				}
#ifndef WASTE_MEM
				FreeARServerInfoList(&serverInfo, FALSE);
				free(requestList.requestList);
#endif
			}
		} else {
			(void) ARError_add(AR_RETURN_ERROR, AP_ERR_MALLOC);
		} 
	  }
	}

HV *
ars_GetCharMenu(ctrl,name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  unsigned int       refreshCode;
	  ARCharMenuStruct   menuDefn;
	  char	            *helpText;
	  ARTimestamp	     timestamp;
	  ARNameType	     owner;
	  ARNameType	     lastChanged;
	  char		    *changeDiary;
	  ARStatusList	     status;
	  int                ret;
	  HV		    *menuDef = newHV();
	  SV		    *ref;

	  (void) ARError_reset();
	  RETVAL = newHV();
	  ret = ARGetCharMenu(ctrl, name, &refreshCode, &menuDefn, &helpText, &timestamp, owner, lastChanged, &changeDiary, &status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if(!ARError(ret, status)) {
		hv_store(RETVAL, "name", strlen("name"),
				newSVpv(name, 0), 0);
		if(helpText)
			hv_store(RETVAL, "helpText", strlen("helpText"),
				newSVpv(helpText,0), 0);
		hv_store(RETVAL, "timestamp", strlen("timestamp"),
			newSViv(timestamp), 0);
		hv_store(RETVAL, "owner", strlen("owner"),
			newSVpv(owner, 0), 0);
		hv_store(RETVAL, "lastChanged", strlen("lastChanged"),
			newSVpv(lastChanged, 0), 0);
		if(changeDiary)
			hv_store(RETVAL, "changeDiary", strlen("changeDiary"),
				newSVpv(changeDiary, 0), 0);
		hv_store(RETVAL, "menuType", strlen("menuType"),
			newSViv(menuDefn.menuType), 0);
		switch(menuDefn.menuType) {
		case AR_CHAR_MENU_QUERY:
			hv_store(menuDef, "schema", strlen("schema"),
				newSVpv(menuDefn.u.menuQuery.schema, 0), 0);
			hv_store(menuDef, "server", strlen("server"),
				newSVpv(menuDefn.u.menuQuery.server, 0), 0);
			hv_store(menuDef, "labelField", strlen("labelField"),
				newSViv(menuDefn.u.menuQuery.labelField), 0);
			hv_store(menuDef, "valueField", strlen("valueField"),
				newSViv(menuDefn.u.menuQuery.valueField), 0);
			hv_store(menuDef, "sortOnLabel", strlen("sortOnLabel"),
				newSViv(menuDefn.u.menuQuery.sortOnLabel), 0);
			ref = newSViv(0);
			sv_setref_pv(ref, "ARQualifierStructPtr", dup_qualifier((void *)&(menuDefn.u.menuQuery.qualifier)));
			hv_store(RETVAL, "qualifier", strlen("qualifier"), ref, 0);
			hv_store(RETVAL, "menuQuery", strlen("menuQuery"),
				newRV((SV *)menuDef), 0);
			break;
		case AR_CHAR_MENU_FILE:
			hv_store(menuDef, "fileLocation", strlen("fileLocation"),
				newSViv(menuDefn.u.menuFile.fileLocation), 0);
			hv_store(menuDef, "filename", strlen("filename"),
				newSVpv(menuDefn.u.menuFile.filename, 0), 0);
			hv_store(RETVAL, "menuFile", strlen("menuFile"),
				newRV((SV *)menuDef), 0);
			break;
#ifndef ARS20
		case AR_CHAR_MENU_SQL:
			hv_store(menuDef, "server", strlen("server"),
				newSVpv(menuDefn.u.menuSQL.server, 0), 0);
			hv_store(menuDef, "sqlCommand", strlen("sqlCommand"),
				newSVpv(menuDefn.u.menuSQL.sqlCommand, 0), 0);
			hv_store(menuDef, "labelIndex", strlen("labelIndex"),
				newSViv(menuDefn.u.menuSQL.labelIndex), 0);
			hv_store(menuDef, "valueIndex", strlen("valueIndex"),
				newSViv(menuDefn.u.menuSQL.valueIndex), 0);
			hv_store(RETVAL, "menuSQL", strlen("menuSQL"),
				newRV((SV *)menuDef), 0);
			break;
#endif
		}
#ifndef WASTE_MEM
		FreeARCharMenuStruct(&menuDefn, FALSE);
		if(helpText) free(helpText);
		if(changeDiary) free(changeDiary);
#endif
	  }
	}
	OUTPUT:
	RETVAL

void
ars_GetCharMenuItems(ctrl,name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  ARCharMenuStruct menuDefn;
      	  ARStatusList status;
	  int ret;

	  (void) ARError_reset();
	  ret = ARGetCharMenu(ctrl, name, NULL, &menuDefn, NULL, NULL, NULL, NULL, NULL, &status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if (! ARError(ret,status)) {
	    ST(0) = sv_2mortal(perl_expandARCharMenuStruct(ctrl, &menuDefn));
#ifndef WASTE_MEM
	    FreeARCharMenuStruct(&menuDefn,FALSE);
#endif
	  } else {
	    ST(0) = &sv_undef;
	  }
	}

HV *
ars_GetSchema(ctrl,name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  ARStatusList status;
	  int ret;
#if AR_EXPORT_VERSION >= 3
	  ARPermissionList groupList;
#else
	  ARInternalIdList groupList;
#endif
	  ARInternalIdList adminGroupList;
	  AREntryListFieldList getListFields;
	  ARIndexList indexList;
	  char *helpText;
	  ARTimestamp timestamp;
	  ARNameType owner;
	  ARNameType lastChanged;
	  char *changeDiary;
#if AR_EXPORT_VERSION >= 3
	  ARCompoundSchema schema;
	  ARSortList sortList;
#endif

	  (void) ARError_reset();
	  RETVAL = newHV();
#if AR_EXPORT_VERSION >= 3
	  ret = ARGetSchema(ctrl, name, &schema, &groupList, &adminGroupList, &getListFields, &sortList, &indexList, &helpText, &timestamp, owner, lastChanged, &changeDiary, &status);
#else
	  ret = ARGetSchema(ctrl, name, &groupList, &adminGroupList, &getListFields, &indexList, &helpText, &timestamp, owner, lastChanged, &changeDiary, &status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if (!ARError(ret,status)) {
#if AR_EXPORT_VERSION >= 3
	    hv_store(RETVAL, "groupList", 9,
		     perl_ARPermissionList(&groupList), 0);
#else
	    hv_store(RETVAL, "groupList", strlen("groupList"),
		     perl_ARList((ARList *)&groupList, 
				 (ARS_fn)perl_ARInternalId,
				 sizeof(ARInternalId)),0);
#endif
	    hv_store(RETVAL, "adminList", strlen("adminList"),
		     perl_ARList((ARList *)&groupList, 
				 (ARS_fn)perl_ARInternalId,
				 sizeof(ARInternalId)),0);
	    hv_store(RETVAL, "getListFields", strlen("getListFields"),
		     perl_ARList((ARList *)&getListFields,
				 (ARS_fn)perl_AREntryListFieldStruct,
				 sizeof(AREntryListFieldStruct)),0);
	    hv_store(RETVAL, "indexList", strlen("indexList"),
		     perl_ARList((ARList *)&indexList,
				 (ARS_fn)perl_ARIndexStruct,
				 sizeof(ARIndexStruct)), 0);
	    if (helpText)
	      hv_store(RETVAL, "helpText", strlen("helpText"),
		       newSVpv(helpText, 0), 0);
	    hv_store(RETVAL, "timestamp", strlen("timestamp"),
		     newSViv(timestamp), 0);
	    hv_store(RETVAL, "owner", strlen("owner"),
		     newSVpv(owner, 0), 0);
	    hv_store(RETVAL, "lastChanged", strlen("lastChanged"),
		     newSVpv(lastChanged, 0), 0);
	    if (changeDiary)
	      hv_store(RETVAL, "changeDiary", strlen("changeDiary"),
		       newSVpv(changeDiary, 0), 0);
#if AR_EXPORT_VERSION >= 3
	    hv_store(RETVAL, "schema", 6, perl_ARCompoundSchema(&schema), 0);
	    hv_store(RETVAL, "sortList", 8, perl_ARSortList(&sortList), 0);
#endif
#ifndef WASTE_MEM
#if AR_EXPORT_VERSION >= 3
	    FreeARPermissionList(&groupList,FALSE);
#else
	    FreeARInternalIdList(&groupList,FALSE);
#endif
	    FreeARInternalIdList(&adminGroupList,FALSE);
	    FreeAREntryListFieldList(&getListFields,FALSE);
	    FreeARIndexList(&indexList,FALSE);
	    if(helpText)
	      free(helpText);
	    if(changeDiary)
	      free(changeDiary);
#if AR_EXPORT_VERSION >= 3
	    FreeARCompoundSchema(&schema,FALSE);
	    FreeARSortList(&sortList,FALSE);
#endif
#endif
	  }
	}
	OUTPUT:
	RETVAL

void
ars_GetListActiveLink(ctrl,schema=NULL,changedSince=0)
	ARControlStruct *	ctrl
	char *			schema
	int			changedSince
	PPCODE:
	{
	  ARNameList nameList;
	  ARStatusList status;
	  int ret, i;

	  (void) ARError_reset();
	  ret=ARGetListActiveLink(ctrl,schema,changedSince,&nameList,&status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if (! ARError(ret,status)) {
	    for (i=0; i<nameList.numItems; i++)
	      XPUSHs(sv_2mortal(newSVpv(nameList.nameList[i],0)));
#ifndef WASTE_MEM
	    FreeARNameList(&nameList,FALSE);
#endif
	  }
	}

HV *
ars_GetField(ctrl,schema,id)
	ARControlStruct *	ctrl
	char *			schema
	unsigned long		id
	CODE:
	{
	  int ret;
	  ARStatusList Status;
	  unsigned int dataType, option, createMode;
	  ARValueStruct defaultVal;
	  ARPermissionList permissions;
	  ARFieldLimitStruct limit;
#if AR_EXPORT_VERSION >= 3
	  ARNameType fieldName;
	  ARFieldMappingStruct fieldMap;
	  ARDisplayInstanceList displayList;
#else
	  ARDisplayList displayList;
#endif
	  char *helpText;
	  ARTimestamp timestamp;
	  ARNameType owner;
	  ARNameType lastChanged;
	  char *changeDiary;
	  
	  (void) ARError_reset();
	  RETVAL = newHV();
#if AR_EXPORT_VERSION >= 3
	  ret = ARGetFieldCached(ctrl, schema, id, fieldName, &fieldMap, &dataType, &option, &createMode, &defaultVal, NULL /* &permissions */, &limit, &displayList, &helpText, &timestamp, owner, lastChanged, &changeDiary, &Status);
#else
	  ret = ARGetFieldCached(ctrl, schema, id, &dataType, &option, &createMode, &defaultVal, NULL /* &permissions */, &limit, &displayList, &helpText, &timestamp, owner, lastChanged, &changeDiary, &Status);
#endif
	  if (! ARError(ret, Status)) {
	    /* store field id for convenience */
	    hv_store(RETVAL, "fieldId", strlen("fieldId"),
		     newSViv(id), 0);
	    if (createMode == AR_FIELD_OPEN_AT_CREATE)
	      hv_store(RETVAL, "createMode", strlen("createMode"),
		       newSVpv("open",0), 0);
	    else
	      hv_store(RETVAL, "createMode", strlen("createMode"),
		       newSVpv("protected",0), 0);
	    hv_store(RETVAL, "option", strlen("option"),
		     newSViv(option), 0);
	    hv_store(RETVAL, "dataType", strlen("dataType"),
		     perl_dataType_names(&dataType), 0);
	    hv_store(RETVAL, "defaultVal", strlen("defaultVal"),
		     perl_ARValueStruct(&defaultVal), 0);
	    /* permissions below */
	    hv_store(RETVAL, "limit", strlen("limit"),
		     perl_ARFieldLimitStruct(&limit), 0);
#if AR_EXPORT_VERSION >= 3
	    hv_store(RETVAL, "fieldName", strlen("fieldName"),
		     newSVpv(fieldName, 0), 0);
	    hv_store(RETVAL, "fieldMap", strlen("fieldMap"),
		     perl_ARFieldMappingStruct(&fieldMap), 0);
	    hv_store(RETVAL, "displayInstanceList",
		     strlen("displayInstanceList"),
		     perl_ARDisplayInstanceList(&displayList), 0);
#else
	    hv_store(RETVAL, "displayList", strlen("displayList"),
		     perl_ARList((ARList *)&displayList,
				 (ARS_fn)perl_ARDisplayStruct,
				 sizeof(ARDisplayStruct)), 0);
#endif
	    if (helpText)
	      hv_store(RETVAL, "helpText", strlen("helpText"),
		       newSVpv(helpText, 0), 0);
	    hv_store(RETVAL, "timestamp", strlen("timestamp"),
		     newSViv(timestamp), 0);
	    hv_store(RETVAL, "owner", strlen("owner"),
		     newSVpv(owner, 0), 0);
	    hv_store(RETVAL, "lastChanged", strlen("lastChanged"),
		     newSVpv(lastChanged, 0), 0);
	    if (changeDiary)
	      hv_store(RETVAL, "changeDiary", strlen("changeDiary"),
		       newSVpv(changeDiary, 0), 0);
#ifndef WASTE_MEM
	    FreeARFieldLimitStruct(&limit,FALSE);
#if AR_EXPORT_VERSION >= 3
	    /* FreeARFieldMappingStruct(&fieldMap,FALSE); *//* doesnt exist! */
	    FreeARDisplayInstanceList(&displayList,FALSE);
#else
	    FreeARDisplayList(&displayList,FALSE);
#endif
	    if(helpText)
	      free(helpText);
	    if(changeDiary)
	      free(changeDiary);
#endif
#if AR_EXPORT_VERSION >= 3
	    ret = ARGetField(ctrl, schema, id, NULL, NULL, NULL, NULL, NULL, NULL, &permissions, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &Status);
#else
	    ret = ARGetField(ctrl, schema, id, NULL, NULL, NULL, NULL, &permissions, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &Status);
#endif
	    if (ret == 0) {
	      hv_store(RETVAL, VNAME("permissions"), 
		       perl_ARPermissionList(&permissions), 0);
#ifndef WASTE_MEM
	      FreeARPermissionList(&permissions,FALSE);
#endif
            } else {
#ifndef WASTE_MEM
	      /* We don't call ARError, so free status list manually */
	      FreeARStatusList(&Status, FALSE);
#endif
            } 
	  }
	}
	OUTPUT:
	RETVAL

int
ars_SetEntry(ctrl,schema,entry_id,getTime,...)
	ARControlStruct *	ctrl
	char *			schema
	char *			entry_id
	unsigned long		getTime
	CODE:
	{
	  int              a, i, c = (items - 4) / 2, j;
	  int              offset = 4;
	  ARFieldValueList fieldList;
	  ARStatusList     status;
	  int              ret;
	  unsigned int     dataType;
#if AR_EXPORT_VERSION >= 3
	  unsigned int     option = AR_JOIN_SETOPTION_NONE;
	  SV            **fetch_entry;
	  AREntryIdList   entryList;
	  AV             *input_list;

	  (void) ARError_reset();
	  RETVAL = 0; /* assume error */
	  if ((items - 4) % 2) {
	    option = SvIV(ST(offset));
	    offset ++;
	  }
	  if (c < 1) {
	    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	    goto set_entry_exit;
	  }
#else
	  (void) ARError_reset();
	  RETVAL = 0; /* assume error */
	  if (((items - 4) % 2) || c < 1) {
	    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	    goto set_entry_exit;
	  }
#endif
	  fieldList.numItems = c;
	  fieldList.fieldValueList = MALLOCNN(sizeof(ARFieldValueStruct)*c);
	  for (i=0; i<c; i++) {
	    a = i*2+offset;
	    fieldList.fieldValueList[i].fieldId = SvIV(ST(a));
	    
	    if (! SvOK(ST(a+1))) {
	      /* pass a NULL */
	      fieldList.fieldValueList[i].value.dataType = AR_DATA_TYPE_NULL;
	    } else {
	      /* determine data type and pass value */
#if AR_EXPORT_VERSION >= 3
	      ret = ARGetFieldCached(ctrl, schema, fieldList.fieldValueList[i].fieldId, NULL, NULL, &dataType, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &status);
#else
	      ret = ARGetFieldCached(ctrl, schema, fieldList.fieldValueList[i].fieldId, &dataType, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &status);
#endif
	      if (ARError(ret, status)) {
		goto set_entry_end;
	      }
	      if (sv_to_ARValue(ST(a+1), dataType, &fieldList.fieldValueList[i].value) < 0) {
#ifndef WASTE_MEM
		for (j=0; j<i; j++) {
		  FreeARValueStruct(&fieldList.fieldValueList[j].value, FALSE);
		}
#endif
		goto set_entry_end;
	      }
	    }
	  }
#if AR_EXPORT_VERSION >= 3
	  /* build entryList */
	  if(perl_BuildEntryList(&entryList, entry_id) != 0)
		goto set_entry_end;

	  ret = ARSetEntry(ctrl, schema, &entryList, &fieldList, getTime, option, &status);
#ifndef WASTE_MEM
	  FreeAREntryIdList(&entryList, FALSE);
#endif	  
#else /* ARS2.x */
	  if(!entry_id || !*entry_id) {
		ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_EID);
		goto set_entry_end;
	  }
	  ret = ARSetEntry(ctrl, schema, entry_id, &fieldList, getTime, &status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if (! ARError(ret, status)) {
	    RETVAL = 1;
	  }
#ifndef WASTE_MEM
	  for (j=0; j<c; j++) {
	    FreeARValueStruct(&fieldList.fieldValueList[j].value, FALSE);
	  }
#endif
	set_entry_end:;
#ifndef WASTE_MEM
	free(fieldList.fieldValueList);
#endif
	set_entry_exit:;
	}
	OUTPUT:
	RETVAL

void
ars_Export(ctrl,displayTag,...)
	ARControlStruct *	ctrl
	char *			displayTag
	PPCODE:
	{
	  int ret, i, a, c = (items - 2) / 2;
	  ARStructItemList structItems;
	  char *buf;
	  ARStatusList status;
	  
	  (void) ARError_reset();
	  if (items % 2 || c < 1) {
	    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  } else {
	    structItems.numItems = c;
	    structItems.structItemList = MALLOCNN(sizeof(ARStructItemStruct)*c);
	    for (i=0; i<c; i++) {
	      a = i*2+2;
	      if (strcmp(SvPV(ST(a),na),"Schema")==0)
		structItems.structItemList[i].type=AR_STRUCT_ITEM_SCHEMA;
	      else if (strcmp(SvPV(ST(a),na),"Schema_Defn")==0)
		structItems.structItemList[i].type=AR_STRUCT_ITEM_SCHEMA_DEFN;
	      else if (strcmp(SvPV(ST(a),na),"Schema_View")==0)
		structItems.structItemList[i].type=AR_STRUCT_ITEM_SCHEMA_VIEW;
	      else if (strcmp(SvPV(ST(a),na),"Schema_Mail")==0)
		structItems.structItemList[i].type=AR_STRUCT_ITEM_SCHEMA_MAIL;
	      else if (strcmp(SvPV(ST(a),na),"Filter")==0)
		structItems.structItemList[i].type=AR_STRUCT_ITEM_FILTER;
	      else if (strcmp(SvPV(ST(a),na),"Active_Link")==0)
		structItems.structItemList[i].type=AR_STRUCT_ITEM_ACTIVE_LINK;
	      else if (strcmp(SvPV(ST(a),na),"Admin_Ext")==0)
		structItems.structItemList[i].type=AR_STRUCT_ITEM_ADMIN_EXT;
	      else if (strcmp(SvPV(ST(a),na),"Char_Menu")==0)
		structItems.structItemList[i].type=AR_STRUCT_ITEM_CHAR_MENU;
	      else if (strcmp(SvPV(ST(a),na),"Escalation")==0)
		structItems.structItemList[i].type=AR_STRUCT_ITEM_ESCALATION;
	      else {
	        (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_EXP);
#ifndef WASTE_MEM
		free(structItems.structItemList);
#endif
		goto export_end;
	      }
	      strncpy(structItems.structItemList[i].name,SvPV(ST(a+1),na), sizeof(ARNameType));
	      structItems.structItemList[i].name[sizeof(ARNameType)-1] = '\0';
	    }
	    ret = ARExport(ctrl, &structItems, displayTag, &buf, &status);
#ifdef PROFILE
	    ((ars_ctrl *)ctrl)->queries++;
#endif
	    if (ARError(ret, status)) {
#ifndef WASTE_MEM
	      free(structItems.structItemList);
#endif
	      goto export_end;
	    }
	    XPUSHs(newSVpv(buf,0));
#ifndef WASTE_MEM
	    free(buf);
#endif
	  }
	export_end:;
	}

int
ars_Import(ctrl,importBuf,...)
	ARControlStruct *	ctrl
	char *			importBuf
	CODE:
	{
	  int ret = 1, i, a, c = (items - 2) / 2;
	  ARStructItemList *structItems = NULL;
	  ARStatusList status;

	  (void) ARError_reset();	  
	  if (items % 2) {
	    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  } else {
	    if (c > 0) {
	      structItems = MALLOCNN(sizeof(ARStructItemList));
	      structItems->numItems = c;
	      structItems->structItemList = MALLOCNN(sizeof(ARStructItemStruct)*c);
	      for (i=0; i<c; i++) {
		a = i*2+2;
		if (strcmp(SvPV(ST(a),na),"Schema")==0)
		  structItems->structItemList[i].type=AR_STRUCT_ITEM_SCHEMA;
		else if (strcmp(SvPV(ST(a),na),"Schema_Defn")==0)
		  structItems->structItemList[i].type=AR_STRUCT_ITEM_SCHEMA_DEFN;
		else if (strcmp(SvPV(ST(a),na),"Schema_View")==0)
		  structItems->structItemList[i].type=AR_STRUCT_ITEM_SCHEMA_VIEW;
		else if (strcmp(SvPV(ST(a),na),"Schema_Mail")==0)
		  structItems->structItemList[i].type=AR_STRUCT_ITEM_SCHEMA_MAIL;
		else if (strcmp(SvPV(ST(a),na),"Filter")==0)
		  structItems->structItemList[i].type=AR_STRUCT_ITEM_FILTER;
		else if (strcmp(SvPV(ST(a),na),"Active_Link")==0)
		  structItems->structItemList[i].type=AR_STRUCT_ITEM_ACTIVE_LINK;
		else if (strcmp(SvPV(ST(a),na),"Admin_Ext")==0)
		  structItems->structItemList[i].type=AR_STRUCT_ITEM_ADMIN_EXT;
		else if (strcmp(SvPV(ST(a),na),"Char_Menu")==0)
		  structItems->structItemList[i].type=AR_STRUCT_ITEM_CHAR_MENU;
		else if (strcmp(SvPV(ST(a),na),"Escalation")==0)
		  structItems->structItemList[i].type=AR_STRUCT_ITEM_ESCALATION;
		else {
	          (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_IMP);
#ifndef WASTE_MEM
		  free(structItems->structItemList);
		  free(structItems);
#endif
		  goto export_end;
		}
		strncpy(structItems->structItemList[i].name,SvPV(ST(a+1),na), sizeof(ARNameType));
		structItems->structItemList[i].name[sizeof(ARNameType)-1] = '\0';
	      }
	    }
	    ret = ARImport(ctrl, structItems, importBuf, &status);
#ifdef PROFILE
	    ((ars_ctrl *)ctrl)->queries++;
#endif
	    if (ARError(ret, status)) {
#ifndef WASTE_MEM
	      if (structItems) {
		free(structItems->structItemList);
		free(structItems);
	      }
#endif
	      goto export_end;
	    }
	  }
	export_end:;
	  RETVAL = ! ret;
	}
	OUTPUT:
	RETVAL

void
ars_GetListFilter(control,schema=NULL,changedsince=0)
	ARControlStruct *	control
	char *			schema
	unsigned long		changedsince
	PPCODE:
	{
	  ARNameList nameList;
	  ARStatusList status;
	  int ret, i;

	  (void) ARError_reset();
	  ret = ARGetListFilter(control,schema,changedsince,&nameList,&status);
#ifdef PROFILE
	  ((ars_ctrl *)control)->queries++;
#endif
	  if (!ARError(ret,status)) {
	    for (i=0; i<nameList.numItems; i++)
	      XPUSHs(sv_2mortal(newSVpv(nameList.nameList[i], 0)));
#ifndef WASTE_MEM
	    FreeARNameList(&nameList,FALSE);
#endif
	  }
	}

void
ars_GetListEscalation(control,schema=NULL,changedsince=0)
	ARControlStruct *	control
	char *			schema
	unsigned long		changedsince
	PPCODE:
	{
	  ARNameList nameList;
	  ARStatusList status;
	  int ret, i;

	  (void) ARError_reset();
	  ret = ARGetListEscalation(control,schema,changedsince,&nameList,&status);
#ifdef PROFILE
	  ((ars_ctrl *)control)->queries++;
#endif
	  if (!ARError(ret,status)) {
	    for (i=0; i<nameList.numItems; i++)
	      XPUSHs(sv_2mortal(newSVpv(nameList.nameList[i], 0)));
#ifndef WASTE_MEM
	    FreeARNameList(&nameList,FALSE);
#endif
	  }
	}

void
ars_GetListCharMenu(control,changedsince=0)
	ARControlStruct *	control
	unsigned long		changedsince
	PPCODE:
	{
	  ARNameList nameList;
	  ARStatusList status;
	  int ret, i;

	  (void) ARError_reset();
	  ret = ARGetListCharMenu(control,changedsince,&nameList,&status);
#ifdef PROFILE
	  ((ars_ctrl *)control)->queries++;
#endif

	  if (!ARError(ret,status)) {
	    for (i=0; i<nameList.numItems; i++)
	      XPUSHs(sv_2mortal(newSVpv(nameList.nameList[i], 0)));
#ifndef WASTE_MEM
	    FreeARNameList(&nameList,FALSE);
#endif
	  }
	}


void
ars_GetListAdminExtension(control,changedsince=0)
	ARControlStruct *	control
	unsigned long		changedsince
	PPCODE:
	{
	  ARNameList nameList;
	  ARStatusList status;
	  int ret, i;

	  (void) ARError_reset();
	  ret = ARGetListAdminExtension(control,changedsince,&nameList,&status);
#ifdef PROFILE
	  ((ars_ctrl *)control)->queries++;
#endif
	  if (!ARError(ret,status)) {
	    for (i=0; i<nameList.numItems; i++)
	      XPUSHs(sv_2mortal(newSVpv(nameList.nameList[i], 0)));
#ifndef WASTE_MEM
	    FreeARNameList(&nameList,FALSE);
#endif
	  }
	}

int
ars_DeleteActiveLink(ctrl, name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  ARStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
	  if(ctrl && name && *name) {
		ret = ARDeleteActiveLink(ctrl, name, &status);
#ifdef PROFILE
	        ((ars_ctrl *)ctrl)->queries++;
#endif		
	        if(!ARError(ret, status)) {
			RETVAL = 1;
		}
	  } else {
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  }
	}
	OUTPUT:
	RETVAL

int
ars_DeleteVUI(ctrl, schema, vuiId)
	ARControlStruct *	ctrl
	char *			schema
	ARInternalId		vuiId
	CODE:
	{
	  ARStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
#if AR_EXPORT_VERSION >= 3
	  if(ctrl && CVLD(schema)) {
		ret = ARDeleteVUI(ctrl, schema, vuiId, &status);
#ifdef PROFILE
	        ((ars_ctrl *)ctrl)->queries++;
#endif
		if(!ARError(ret, status)) {
			RETVAL = 1;
		}
	  } else {
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  }
#else /* 2.x */
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_DEPRECATED, "DeleteVUI() is only available in ARS3.x");
#endif
	}
	OUTPUT:
	RETVAL

int
ars_DeleteAdminExtension(ctrl, name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  ARStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
	  if(ctrl && name && *name) {
		ret = ARDeleteAdminExtension(ctrl, name, &status);
#ifdef PROFILE
	        ((ars_ctrl *)ctrl)->queries++;
#endif
	        if(!ARError(ret, status)) {
			RETVAL = 1;
		}
	  } else {
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  }
	}
	OUTPUT:
	RETVAL

int
ars_DeleteCharMenu(ctrl, name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  ARStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
	  if(ctrl && name && *name) {
		ret = ARDeleteCharMenu(ctrl, name, &status);
#ifdef PROFILE
	        ((ars_ctrl *)ctrl)->queries++;
#endif
		if(!ARError(ret, status)) {
			RETVAL = 1;
		}
	  } else {
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  }
	}
	OUTPUT:
	RETVAL

int
ars_DeleteEscalation(ctrl, name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  ARStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
	  if(ctrl && name && *name) {
		ret = ARDeleteEscalation(ctrl, name, &status);
#ifdef PROFILE
	        ((ars_ctrl *)ctrl)->queries++;
#endif
		if(!ARError(ret, status)) {
			RETVAL = 1;
		}
	  } else {
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  }
	}
	OUTPUT:
	RETVAL

int
ars_DeleteField(ctrl, schema, fieldId, deleteOption=0)
	ARControlStruct *	ctrl
	char * 			schema
	ARInternalId		fieldId
	unsigned int		deleteOption
	CODE:
	{
	  ARStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
	  if(ctrl && CVLD(schema) && IVLD(deleteOption, 0, 2)) {
		ret = ARDeleteField(ctrl, schema, fieldId, deleteOption, &status);
#ifdef PROFILE
	        ((ars_ctrl *)ctrl)->queries++;
#endif
		if(!ARError(ret, status)) {
			RETVAL = 1;
		}
	  } else {
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  }
	}
	OUTPUT:
	RETVAL

int
ars_DeleteFilter(ctrl, name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  ARStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
	  if(ctrl && name && *name) {
		ret = ARDeleteFilter(ctrl, name, &status);
#ifdef PROFILE
	        ((ars_ctrl *)ctrl)->queries++;
#endif
		if(!ARError(ret, status)) {
			RETVAL = 1;
		}
	  } else {
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  }
	}
	OUTPUT:
	RETVAL

int
ars_DeleteSchema(ctrl, name, deleteOption)
	ARControlStruct *	ctrl
	char *			name
	unsigned int 		deleteOption
	CODE:
	{
	  ARStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
	  if(ctrl && CVLD(name)) {
		ret = ARDeleteSchema(ctrl, name, deleteOption, &status);
#ifdef PROFILE
	        ((ars_ctrl *)ctrl)->queries++;
#endif
		if(!ARError(ret, status))
			RETVAL = 1;
	  } else
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	}
	OUTPUT:
	RETVAL

int
ars_DeleteMultipleFields(ctrl, schema, deleteOption, ...)
	ARControlStruct	*	ctrl
	char *			schema
	unsigned int		deleteOption
	CODE:
	{
	  int i, ret, c = (items - 3);
	  ARStatusList status;
	  ARInternalIdList fieldList;

	  RETVAL = 0; /* assume error */
	  (void) ARError_reset();
#if AR_EXPORT_VERSION >= 3
	  if(items < 4)
	     (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  else {
	     /* slurp in each fieldId and put it in a list */
	     fieldList.numItems = c;
	     fieldList.internalIdList = MALLOCNN(sizeof(ARInternalId) * c);
	     for(i = 0; i < c; i++) {
		fieldList.internalIdList[i] = SvIV(ST(i + 3));
	     }
	     ret = ARDeleteMultipleFields(ctrl, schema, &fieldList, deleteOption, &status);
#ifdef PROFILE
	     ((ars_ctrl *)ctrl)->queries++;
#endif
	     if(!ARError(ret, status))
		RETVAL = 1;
#ifndef WASTE_MEM
	     FreeARInternalIdList(&fieldList, FALSE);
#endif
	  }
#else /* 2.x */
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_DEPRECATED, "Not available in 2.x");
#endif
	}
	OUTPUT:
	RETVAL

int
ars_ExecuteAdminExtension(ctrl, name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	 ARStatusList status;
	 int ret;

	 RETVAL = 0;
	 (void) ARError_reset();
	 if(ctrl && CVLD(name))
		ret = ARExecuteAdminExtension(ctrl, name, &status);
#ifdef PROFILE
	 ((ars_ctrl *)ctrl)->queries++;
#endif
	 if(!ARError(ret, status))
		RETVAL = 1;
	}
	OUTPUT:
	RETVAL

void
ars_ExecuteProcess(ctrl, command, runOption=0)
	ARControlStruct *	ctrl
	char *			command
	int			runOption
	PPCODE:
	{
	 ARStatusList status;
	 int    returnStatus;
	 char  *returnString;
	 int    ret;

	 (void) ARError_reset();
#if AR_EXPORT_VERSION >= 3
	 if(ctrl && CVLD(command)) {
		if(runOption == 0)
			ret = ARExecuteProcess(ctrl, command, &returnStatus, &returnString, &status);
		else
			ret = ARExecuteProcess(ctrl, command, NULL, NULL, &status);
	 }
#ifdef PROFILE
	 ((ars_ctrl *)ctrl)->queries++;
#endif
	 /* if all went well, and user requested synchronous processing 
	  * then we push the returnStatus and returnString back out to them.
	  * if they requested async, then we just push a 1 to indicate that the
	  * command to the API was successfully handled (and foo || die constructs
	  * will work correctly).
	  */
	 if(!ARError(ret, status)) {
		if(runOption == 0) {
			XPUSHs(sv_2mortal(newSViv(returnStatus)));
			XPUSHs(sv_2mortal(newSVpv(returnString, 0)));
#ifndef WASTE_MEM
			if(CVLD(returnString)) free(returnString);
#endif
		} else {
			XPUSHs(sv_2mortal(newSViv(1)));
		}
	 }
#else /* 2.x */
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_DEPRECATED, "Not available in 2.x");
#endif
	}

HV *
ars_GetAdminExtension(ctrl, name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	 ARStatusList  status;
	 ARInternalIdList groupList;
	 char          command[AR_MAX_COMMAND_SIZE];
	 char         *helpText;
	 ARTimestamp   timestamp;
	 ARNameType    owner;
	 ARNameType    lastChanged;
	 char         *changeDiary;
	 int           ret;

	 (void) ARError_reset();
	 RETVAL = newHV();
	 ret = ARGetAdminExtension(ctrl, name, &groupList, command, &helpText, &timestamp, owner, lastChanged, &changeDiary, &status);
#ifdef PROFILE
	 ((ars_ctrl *)ctrl)->queries++;
#endif
	 if(!ARError(ret, status)) {
	  	hv_store(RETVAL, VNAME("name"), newSVpv(name, 0), 0);
		hv_store(RETVAL, VNAME("groupList"),
			perl_ARList((ARList *)&groupList, 
				    (ARS_fn)perl_ARInternalId,
				    sizeof(ARInternalId)), 0);
		hv_store(RETVAL, VNAME("command")  , newSVpv(command, 0), 0);
		hv_store(RETVAL, VNAME("helpText") , newSVpv(helpText, 0), 0);
		hv_store(RETVAL, VNAME("timestamp"), newSViv(timestamp), 0);
		hv_store(RETVAL, VNAME("owner")    , newSVpv(owner, 0), 0);
		hv_store(RETVAL, VNAME("lastChanged"), newSVpv(lastChanged, 0), 0);
		hv_store(RETVAL, VNAME("changeDiary"), newSVpv(changeDiary, 0), 0);
#ifndef WASTE_MEM
		FreeARInternalIdList(&groupList, FALSE);
		if(helpText) free(helpText);
		if(changeDiary) free(changeDiary);
#endif
	 }
	}
	OUTPUT:
	RETVAL

HV *
ars_GetEscalation(ctrl, name)
	ARControlStruct *	ctrl
	char *			name
	CODE:
	{
	  ARStatusList         status;
	  AREscalationTmStruct escalationTm;
	  ARNameType           schema;
	  unsigned int         enable;
	  ARFilterActionList   actionList;
#if AR_EXPORT_VERSION >= 3
	  ARFilterActionList   elseList;
#endif
	  char                *helpText;
	  ARTimestamp          timestamp;
	  ARNameType           owner;
	  ARNameType           lastChanged;
          char                *changeDiary;
	  SV                  *ref;
	  int                  ret;
	  ARQualifierStruct   *query = MALLOCNN(sizeof(ARQualifierStruct));

	  RETVAL = newHV();
	  (void) ARError_reset();
#if AR_EXPORT_VERSION >= 3
	  ret = ARGetEscalation(ctrl, name, &escalationTm, schema, &enable,
			query, &actionList, &elseList, &helpText, &timestamp,
			owner, lastChanged, &changeDiary, &status);
#else
	  ret = ARGetEscalation(ctrl, name, &escalationTm, schema, &enable,
			query, &actionList,            &helpText, &timestamp,
			owner, lastChanged, &changeDiary, &status);
#endif
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if(!ARError(ret, status)) {
	     hv_store(RETVAL, VNAME("name"), newSVpv(name, 0), 0);
	     hv_store(RETVAL, VNAME("schema"), newSVpv(schema, 0), 0);
	     hv_store(RETVAL, VNAME("enable"), newSViv(enable), 0);
	     hv_store(RETVAL, VNAME("helpText"), newSVpv(helpText, 0), 0);
	     hv_store(RETVAL, VNAME("owner"), newSVpv(owner, 0), 0);
	     hv_store(RETVAL, VNAME("lastChanged"), newSVpv(lastChanged, 0), 0);
	     hv_store(RETVAL, VNAME("changeDiary"), newSVpv(changeDiary, 0), 0);
	     ref = newSViv(0);
	     sv_setref_pv(ref, "ARQualifierStructPtr", (void *)query);
	     hv_store(RETVAL, VNAME("query"), ref, 0);
	     hv_store(RETVAL, VNAME("actionList"),
			perl_ARList((ARList *)&actionList,
				(ARS_fn)perl_ARActiveLinkActionStruct,
				sizeof(ARActiveLinkActionStruct)), 0);
#if AR_EXPORT_VERSION >= 3
	     hv_store(RETVAL, VNAME("elseList"), 
			perl_ARList((ARList *)&elseList,
				(ARS_fn)perl_ARActiveLinkActionStruct,
				sizeof(ARActiveLinkActionStruct)), 0);
#endif
	     hv_store(RETVAL, VNAME("TmType"), newSViv(escalationTm.escalationTmType), 0);
	     switch(escalationTm.escalationTmType) {
	     case AR_ESCALATION_TYPE_INTERVAL:
		hv_store(RETVAL, VNAME("TmInterval"), 
			newSViv(escalationTm.u.interval), 0);
		break;
	     case AR_ESCALATION_TYPE_TIMEMARK:
		hv_store(RETVAL, VNAME("TmMonthDayMask"),
			newSViv(escalationTm.u.date.monthday), 0);
		hv_store(RETVAL, VNAME("TmWeekDayMask"),
			newSViv(escalationTm.u.date.weekday), 0);
		hv_store(RETVAL, VNAME("TmHourMask"),
			newSViv(escalationTm.u.date.hourmask), 0);
		hv_store(RETVAL, VNAME("TmMinute"),
			newSViv(escalationTm.u.date.minute), 0);
		break;
	     }
#ifndef WASTE_MEM
	     FreeARFilterActionList(&actionList, FALSE);
#if AR_EXPORT_VERSION >= 3
	     FreeARFilterActionList(&elseList, FALSE);
#endif
	     if(helpText) free(helpText);
	     if(changeDiary) free(changeDiary);
#endif
	  }
	}
	OUTPUT:
	RETVAL

HV *
ars_GetFullTextInfo(ctrl)
	ARControlStruct *	ctrl
	CODE:
	{
	  ARFullTextInfoRequestList requestList;
	  ARFullTextInfoList        fullTextInfo;
	  ARStatusList              status;
	  int                       ret;
	  unsigned int rlist[] = {AR_FULLTEXTINFO_CASE_SENSITIVE_SRCH,
			 	  AR_FULLTEXTINFO_COLLECTION_DIR,
			 	  AR_FULLTEXTINFO_FTS_MATCH_OP,
			 	  AR_FULLTEXTINFO_STATE,
			 	  AR_FULLTEXTINFO_STOPWORD};

	  (void) ARError_reset();
	  RETVAL = newHV();
	  requestList.numItems = 5;
	  requestList.requestList = rlist;
	  ret = ARGetFullTextInfo(ctrl, &requestList, &fullTextInfo, &status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if(!ARError(ret, status)) {
	     int i, v;
	     AV *a = newAV();

	     for(i = 0; i < fullTextInfo.numItems ; i++) {
	        switch(fullTextInfo.fullTextInfoList[i].infoType) {
		case AR_FULLTEXTINFO_STOPWORD:
		   for(v = 0; v < fullTextInfo.fullTextInfoList[i].u.valueList.numItems ; v++) {
		      av_push(a, perl_ARValueStruct(&(fullTextInfo.fullTextInfoList[i].u.valueList.valueList[v])));
		   }
		   hv_store(RETVAL, VNAME("StopWords"), newRV((SV *)a), 0);
		   break;
		case AR_FULLTEXTINFO_CASE_SENSITIVE_SRCH:
		   hv_store(RETVAL, VNAME("CaseSensitive"),
			    perl_ARValueStruct(&(fullTextInfo.fullTextInfoList[i].u.value)), 0);
		   break;
		case AR_FULLTEXTINFO_COLLECTION_DIR:
		   hv_store(RETVAL, VNAME("CollectionDir"),
			    perl_ARValueStruct(&(fullTextInfo.fullTextInfoList[i].u.value)), 0);
		   break;
		case AR_FULLTEXTINFO_FTS_MATCH_OP:
		   hv_store(RETVAL, VNAME("MatchOp"),
			    perl_ARValueStruct(&(fullTextInfo.fullTextInfoList[i].u.value)), 0);
		   break;
		case AR_FULLTEXTINFO_STATE:
		   hv_store(RETVAL, VNAME("State"),
			    perl_ARValueStruct(&(fullTextInfo.fullTextInfoList[i].u.value)), 0);
		   break;
		}
	     }
#ifndef WASTE_MEM
             FreeARFullTextInfoList(&fullTextInfo, FALSE);
#endif
	  }
	}
	OUTPUT:
	RETVAL

HV *
ars_GetListGroup(ctrl, userName=NULL)
	ARControlStruct *	ctrl
	char *			userName
	CODE:
	{
	  ARStatusList    status;
	  ARGroupInfoList groupList;
	  int i, v, ret;

	  (void) ARError_reset();
	  RETVAL = newHV();
	  ret = ARGetListGroup(ctrl, userName, &groupList, &status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if(!ARError(ret, status)) {
	    AV *gidList = newAV(), *gtypeList = newAV(), 
	       *gnameListList = newAV(), *gnameList;

	    for(i = 0; i < groupList.numItems; i++) {
		av_push(gidList, newSViv(groupList.groupList[i].groupId));
		av_push(gtypeList, newSViv(groupList.groupList[i].groupType));
		gnameList = newAV();
		for(v = 0; v < groupList.groupList[i].groupName.numItems ; v++) {
		   av_push(gnameList, newSVpv(groupList.groupList[i].groupName.nameList[v], 0));
		}
		av_push(gnameListList, newRV((SV *)gnameList));
	    }

	    hv_store(RETVAL, VNAME("groupId"), newRV((SV *)gidList), 0);
	    hv_store(RETVAL, VNAME("groupType"), newRV((SV *)gtypeList), 0);
	    hv_store(RETVAL, VNAME("groupName"), newRV((SV *)gnameListList), 0);
#ifndef WASTE_MEM
	    FreeARGroupInfoList(&groupList, FALSE);
#endif
	  }
	}
	OUTPUT:
	RETVAL

HV *
ars_GetListSQL(ctrl, sqlCommand, maxRetrieve=AR_NO_MAX_LIST_RETRIEVE)
	ARControlStruct *	ctrl
	char *			sqlCommand
	unsigned int		maxRetrieve
	CODE:
	{
	  ARStatusList    status;
	  ARValueListList valueListList;
	  unsigned int    numMatches;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = newHV();
#ifndef ARS20
	  ret = ARGetListSQL(ctrl, sqlCommand, maxRetrieve, &valueListList, 
			     &numMatches, &status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if(!ARError(ret, status)) {
	     int  row, col;
	     AV  *ra = newAV(), *ca;

	     hv_store(RETVAL, VNAME("numMatches"), newSViv(numMatches), 0);
	     for(row = 0; row < valueListList.numItems ; row++) {
		ca = newAV();
		for(col = 0; col < valueListList.valueListList[row].numItems; col++) {
		   av_push(ca, perl_ARValueStruct(&(valueListList.valueListList[row].valueList[col])));
		}
		av_push(ra, newRV((SV *)ca));
	     }
	     hv_store(RETVAL, VNAME("rows"), newRV((SV *)ra), 0);
#ifndef WASTE_MEM
	     FreeARValueListList(&valueListList, FALSE);
#endif
	  }
#else
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_DEPRECATED, "Not available in pre-2.1 ARS");
#endif
	}
	OUTPUT:
	RETVAL

void
ars_GetListUser(ctrl, userListType=AR_USER_LIST_MYSELF)
	ARControlStruct *	ctrl
	unsigned int		userListType
	PPCODE:
	{
	  ARStatusList   status;
	  ARUserInfoList userList;
	  int ret;

	  (void) ARError_reset();
	  ret = ARGetListUser(ctrl, userListType, &userList, &status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if(!ARError(ret, status)) {
	     int i, j;
	     for(i = 0; i < userList.numItems; i++) {
	        HV *userInfo           = newHV();
		AV *licenseTag         = newAV(),
		   *licenseType        = newAV(),
		   *currentLicenseType = newAV();

	        hv_store(userInfo, VNAME("userName"), 
			newSVpv(userList.userList[i].userName, 0), 0);
		hv_store(userInfo, VNAME("connectTime"),
			newSViv(userList.userList[i].connectTime), 0);
		hv_store(userInfo, VNAME("lastAccess"),
			newSViv(userList.userList[i].lastAccess), 0);
		hv_store(userInfo, VNAME("defaultNotifyMech"),
			newSViv(userList.userList[i].defaultNotifyMech), 0);
		hv_store(userInfo, VNAME("emailAddr"),
			newSVpv(userList.userList[i].emailAddr, 0), 0);

		for(j = 0; j < userList.userList[i].licenseInfo.numItems; j++) {
		   av_push(licenseTag, newSViv(userList.userList[i].licenseInfo.licenseList[j].licenseTag));
		   av_push(licenseType, newSViv(userList.userList[i].licenseInfo.licenseList[j].licenseType));
		   av_push(currentLicenseType, newSViv(userList.userList[i].licenseInfo.licenseList[j].currentLicenseType));
		}
		hv_store(userInfo, VNAME("licenseTag"), newRV((SV *)licenseTag), 0);
		hv_store(userInfo, VNAME("licenseType"), newRV((SV *)licenseType), 0);
		hv_store(userInfo, VNAME("currentLicenseType"), newRV((SV *)currentLicenseType), 0);
	        XPUSHs(sv_2mortal(newRV((SV *)userInfo)));
	     }
#ifndef WASTE_MEM
	     FreeARUserInfoList(&userList, FALSE);
#endif
	  }
	}

void
ars_GetListVUI(ctrl, schema, changedSince=0)
	ARControlStruct *	ctrl
	char *			schema
	unsigned int		changedSince
	PPCODE:
	{
#if AR_EXPORT_VERSION >= 3
	  ARStatusList     status;
	  ARInternalIdList idList;
	  int              ret, i;

	  ret = ARGetListVUI(ctrl, schema, changedSince, &idList, &status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if(!ARError(ret, status)) {
	    for(i = 0 ; i < idList.numItems ; i++) {
		XPUSHs(sv_2mortal(newSViv(idList.internalIdList[i])));
	    }
	  }
#ifdef WASTE_MEM
	  FreeARInteralIdList(&idList, FALSE);
#endif
#else /* ars 2.x */
	  (void) ARError_reset();
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_DEPRECATED, "Not available in 2.x");
#endif
	}

void
ars_GetServerInfo(ctrl, ...)
	ARControlStruct *	ctrl
	PPCODE:
	{
	  ARStatusList            status;
	  ARServerInfoRequestList requestList;
	  ARServerInfoList        serverInfo;
	  int                     ret, i, count;
	  unsigned int            rlist[AR_MAX_SERVER_INFO_USED];

	  (void) ARError_reset();

	  count = 0;
	  if(items == 1) { /* none specified.. fetch all */
	     for(i = 0; i < AR_MAX_SERVER_INFO_USED ; i++) {
	        /* we'll exclude ones that can't be retrieved to avoid errors */
	        switch(i+1) {
	        case AR_SERVER_INFO_DB_PASSWORD:
		   break;
	        default:
	           rlist[count++] = i+1;
	        }
             }
	  } 
	  else if(items > AR_MAX_SERVER_INFO_USED + 1) {
	    ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  }
	  else { /* user has asked for specific ones */
	     for(i = 1 ; i < items ; i++) {
		rlist[count++] = SvIV(ST(i));
	     }
	  }

	  if(count > 0) {
	     requestList.numItems = count;
	     requestList.requestList = rlist;

	     ret = ARGetServerInfo(ctrl, &requestList, &serverInfo, &status);
#ifdef PROFILE
	     ((ars_ctrl *)ctrl)->queries++;
#endif
	     if(!ARError(ret, status)) {
	        for(i = 0 ; i < serverInfo.numItems ; i++) {
	  	   XPUSHs(sv_2mortal(newSVpv(ServerInfoMap[serverInfo.serverInfoList[i].operation].name, 0)));
		   XPUSHs(perl_ARValueStruct(&(serverInfo.serverInfoList[i].value)));
	        }
	     }
#ifndef WASTE_MEM
	    FreeARServerInfoList(&serverInfo, FALSE);
#endif
	  }
	}

HV *
ars_GetVUI(ctrl, schema, vuiId)
	ARControlStruct *	ctrl
	char *			schema
	ARInternalId		vuiId
	CODE:
	{
#if AR_EXPORT_VERSION >= 3
	  ARStatusList status;
	  ARNameType   vuiName;
	  ARPropList   dPropList;
	  char        *helpText;
	  ARTimestamp  timestamp;
	  ARNameType   owner;
	  ARNameType   lastChanged;
	  char        *changeDiary;
	  int          i, ret;

	  RETVAL = newHV();
	  (void) ARError_reset();
	  ret = ARGetVUI(ctrl, schema, vuiId, vuiName, &dPropList, &helpText, 
			 &timestamp, owner, lastChanged, &changeDiary, &status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif
	  if(!ARError(ret, status)) {
	     hv_store(RETVAL, VNAME("schema"), newSVpv(schema, 0), 0);
	     hv_store(RETVAL, VNAME("vuiId"), newSViv(vuiId), 0);
	     hv_store(RETVAL, VNAME("vuiName"), newSVpv(vuiName, 0), 0);
	     hv_store(RETVAL, VNAME("owner"), newSVpv(owner, 0), 0);
	     hv_store(RETVAL, VNAME("helpText"), newSVpv(helpText, 0), 0);
	     hv_store(RETVAL, VNAME("lastChanged"), newSVpv(lastChanged, 0), 0);
	     hv_store(RETVAL, VNAME("changeDiary"), newSVpv(changeDiary, 0), 0);
	     hv_store(RETVAL, VNAME("timestamp"), newSViv(timestamp), 0);
	     hv_store(RETVAL, VNAME("props"),
		perl_ARList((ARList *)&dPropList,
			    (ARS_fn)perl_ARPropStruct,
			    sizeof(ARPropStruct)), 0);
	  }
#ifndef WASTE_MEM
	  FreeARPropList(&dPropList, FALSE);
	  if(helpText) free(helpText);
	  if(changeDiary) free(changeDiary);
#endif
#else /* ars 2.x */
	  (void) ARError_reset();
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_DEPRECATED, "Not available in 2.x");
	  RETVAL = newHV();
#endif

	}
	OUTPUT:
	RETVAL

int
ars_CreateCharMenu(ctrl, cmDefRef)
	ARControlStruct *	ctrl
	SV *			cmDefRef
	CODE:
	{
	  int               rv, ret;
	  ARNameType        name;
	  unsigned int      refreshCode;
	  ARCharMenuStruct  menuDefn;
	  char             *helptext;
	  ARNameType        owner;
	  char             *changeDiary;
	  ARStatusList      status;

	  (void) ARError_reset();
	  RETVAL = 0;
	  zeromem(&menuDefn, sizeof(ARCharMenuStruct));
	  zeromem(&owner, sizeof(ARNameType));
	  zeromem(&name, sizeof(ARNameType));

	  if(SvTYPE((SV *)SvRV(cmDefRef)) != SVt_PVHV) {
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_EXPECT_PVHV);
	  } else {
		HV *cmDef = (HV *)SvRV(cmDefRef);
		printf("ars_CreateCharMenu: not implemented");
	  }
	}
	OUTPUT:
	RETVAL

int 
ars_CreateAdminExtension(ctrl, aeDefRef)
	ARControlStruct *	ctrl
	SV *			aeDefRef
	CODE:
	{
	  int               rv = 0, ret = 0;
	  ARNameType        name, owner;
	  ARInternalIdList  groupList;
	  char             *command     = CPNULL, 
			   *helpText    = CPNULL, 
			   *changeDiary = CPNULL;
	  ARStatusList      status;

	  (void) ARError_reset();
	  RETVAL = 0;
	  zeromem(&groupList, sizeof(ARInternalIdList));
	  zeromem(&name, sizeof(ARNameType));
	  zeromem(&owner, sizeof(ARNameType));

	  if(SvTYPE((SV *)SvRV(aeDefRef)) != SVt_PVHV) {
		(void) ARError_add(AR_RETURN_ERROR, AP_ERR_EXPECT_PVHV);
	  } else {
		HV *aeDef = (HV *)SvRV(aeDefRef);
		if(hv_exists(aeDef, VNAME("name")) &&
		   hv_exists(aeDef, VNAME("groupList")) &&
		   hv_exists(aeDef, VNAME("command"))) {

		   rv += strcpyHVal(aeDef, "name", name, sizeof(ARNameType));
		   rv += strmakHVal(aeDef, "command", &command);
		   if(hv_exists(aeDef, VNAME("helpText"))) 
			rv += strmakHVal(aeDef, "helpText", &helpText);
		   if(hv_exists(aeDef, VNAME("changeDiary"))) 
			rv += strmakHVal(aeDef, "changeDiary", &changeDiary);
		   if(hv_exists(aeDef, VNAME("owner"))) 
			rv += strcpyHVal(aeDef, "owner", owner, sizeof(ARNameType));
		   else
			strncpy(owner, ctrl->user, sizeof(ARNameType));

		   rv += rev_ARInternalIdList(aeDef, "groupList", &groupList);

		   if(rv == 0) {
			ret = ARCreateAdminExtension(ctrl, name, &groupList,
					command, helpText, owner, changeDiary,
					&status);
			if(!ARError(ret, status)) RETVAL = 1;
		   } else
			ARError_add(AR_RETURN_ERROR, AP_ERR_PREREVFAIL);

		} else {
		   ARError_add(AR_RETURN_ERROR, AP_ERR_NEEDKEYS);
		   ARError_add(AR_RETURN_ERROR, AP_ERR_NEEDKEYSKEYS,
			"name, groupList, command");
		}
	  }
	}
	OUTPUT:
	RETVAL

int
ars_CreateActiveLink(ctrl, alDefRef)
	ARControlStruct *	ctrl
	SV *			alDefRef
	CODE:
	{
	  int                    ret = 0, i, rv = 0;
	  ARNameType             schema, name;
	  ARInternalIdList       groupList;
	  unsigned int           executeMask, order;
#if AR_EXPORT_VERSION >= 3
	  ARInternalId           controlField = 0;
	  ARInternalId           focusField = 0;
#else /* 2.x */
	  ARInternalId           field = 0;
	  ARDisplayList          displayList;
#endif
	  unsigned int           enable = 0;
	  ARQualifierStruct     *query;
	  ARActiveLinkActionList actionList;
#if AR_EXPORT_VERSION >= 3
	  ARActiveLinkActionList elseList;
#endif
	  char                  *helpText = (char *)NULL;
	  ARNameType             owner;
	  char                  *changeDiary = (char *)NULL;
	  ARStatusList           status;
	  
	  RETVAL = 0; /* assume error */
	  (void) ARError_reset();
	  zeromem(&groupList, sizeof(ARInternalIdList));
	  zeromem(&actionList, sizeof(ARActiveLinkActionList));
#if AR_EXPORT_VERSION >= 3
	  zeromem(&elseList, sizeof(ARActiveLinkActionList));
#else
	  zeromem(&displayList, sizeof(ARDisplayList));
#endif
	  if(SvTYPE((SV *)SvRV(alDefRef)) != SVt_PVHV) {
		ARError_add(AR_RETURN_ERROR, AP_ERR_EXPECT_PVHV);
	  } else {
		HV *alDef = (HV *)SvRV(alDefRef);
		int rv2;
		SV **qhv = hv_fetch(alDef, VNAME("query"), 0);

		/* dereference the qual pointer */

		if(qhv && *qhv && SvROK(*qhv)) {
			query = (ARQualifierStruct *)SvIV((SV *)SvRV(*qhv));
		} else {
			query = (ARQualifierStruct *)NULL;
		}
		/* copy the various hash entries into the appropriate
		 * data structure. if any are missing, we fail.
		 */

		rv  = 0;
		rv += strcpyHVal(alDef, "name", name, sizeof(ARNameType));
		rv += strcpyHVal(alDef, "schema", schema, sizeof(ARNameType));
		rv += uintcpyHVal(alDef, "order", &order);
		rv += rev_ARInternalIdList(alDef, "groupList", &groupList);
		rv += uintcpyHVal(alDef, "executeMask", &executeMask);
		rv += uintcpyHVal(alDef, "enable", &enable);

		if(hv_exists(alDef, VNAME("owner")))
			rv += strcpyHVal(alDef, "owner", owner, sizeof(ARNameType));
		else
			strncpy(owner, ctrl->user, sizeof(ARNameType));

		/* these two are optional, so if the calls return warnings
		 * it probably indicates that the hash keys don't exist and
		 * we'll ignore it unless an actual failure code is returned.
		 */

		if(hv_exists(alDef, VNAME("changeDiary")))
			rv += strmakHVal(alDef, "changeDiary", &changeDiary);
		if(hv_exists(alDef, VNAME("helpText")))
			rv += strmakHVal(alDef, "helpText", &helpText);

		/* now handle the action & else (3.x) lists */

		rv += rev_ARActiveLinkActionList(alDef, "actionList", &actionList);
#if AR_EXPORT_VERSION >= 3
		rv += rev_ARActiveLinkActionList(alDef, "elseList", &elseList);
		if((executeMask & AR_EXECUTE_ON_RETURN) || 
		   (executeMask & AR_EXECUTE_ON_MENU_CHOICE))
			rv += longcpyHVal(alDef, "focusField", &focusField);
		if(executeMask & AR_EXECUTE_ON_BUTTON) 
			rv += longcpyHVal(alDef, "controlField", &controlField);
#else /* 2.x */
		if((executeMask & AR_EXECUTE_ON_RETURN) || 
		   (executeMask & AR_EXECUTE_ON_MENU_CHOICE))
			rv += ulongcpyHVal(alDef, "field", &field);
		if(executeMask & AR_EXECUTE_ON_BUTTON)
			rv += rev_ARDisplayList(alDef, "displayList", 
					&displayList);
#endif
		/* at this point all datastructures (hopefully) are 
		 * built. we can call the api routine to create the
		 * active link.
		 */
		if(rv == 0) {
#if AR_EXPORT_VERSION >= 3
		   ret = ARCreateActiveLink(ctrl, name, order, schema, 
					    &groupList, executeMask,
					    &controlField, &focusField, 
					    enable, query,
					    &actionList, &elseList, 
					    helpText, owner, changeDiary, &status);
#else /* 2.x */
#endif
		   if(!ARError(ret, status))
			   RETVAL = 1;
		} else 
		   ARError_add(AR_RETURN_ERROR, AP_ERR_PREREVFAIL);
	  }
#ifndef WASTE_MEM
	  if(helpText) free(helpText);
	  if(changeDiary) free(changeDiary);
	  (void) FreeARInternalIdList(&groupList, FALSE);
	  (void) FreeARActiveLinkActionList(&actionList, FALSE);
#if AR_EXPORT_VERSION >= 3
	  (void) FreeARActiveLinkActionList(&elseList, FALSE);
#else /* 2.x */
	  (void) FreeARDisplayList(&displayList, FALSE);
#endif
#endif
	}
	OUTPUT:
	RETVAL

char *
ars_MergeEntry(ctrl, schema, mergeType, ...)
	ARControlStruct *	ctrl
	char *			schema
	unsigned int		mergeType
	CODE:
	{
	  int a, i, c = (items - 3) / 2, j;
	  ARFieldValueList fieldList;
	  ARStatusList status;
	  int ret;
	  unsigned int dataType;
	  AREntryIdType entryId;

	  (void) ARError_reset();
	  RETVAL = "";
	  if ((items - 3) % 2 || c < 1) {
	    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	    goto merge_entry_exit;
	  }
	  fieldList.numItems = c;
	  fieldList.fieldValueList = MALLOCNN(sizeof(ARFieldValueStruct)*c);
	  for (i=0; i<c; i++) {
	    a = i*2 + 3;
	    fieldList.fieldValueList[i].fieldId = SvIV(ST(a));
	    if (! SvOK(ST(a+1))) {
	      /* pass a NULL */
	      fieldList.fieldValueList[i].value.dataType = AR_DATA_TYPE_NULL;
	    } else {
#if AR_EXPORT_VERSION >= 3
	      ret = ARGetFieldCached(ctrl, schema, fieldList.fieldValueList[i].fieldId, NULL, NULL, &dataType, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &status);
#else
	      ret = ARGetFieldCached(ctrl, schema, fieldList.fieldValueList[i].fieldId, &dataType, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, &status);
#endif
	      if (ARError(ret, status)) {
		goto merge_entry_end;
	      }
	      if (sv_to_ARValue(ST(a+1), dataType, &fieldList.fieldValueList[i].value) < 0) {
#ifndef WASTE_MEM
		for (j=0; j<i; j++) {
		  FreeARValueStruct(&fieldList.fieldValueList[j].value, FALSE);
		}
#endif
		goto merge_entry_end;
	      }
	    }
	  }
	  ret = ARMergeEntry(ctrl, schema, &fieldList, mergeType, entryId, &status);
#ifdef PROFILE
	  ((ars_ctrl *)ctrl)->queries++;
#endif	  
	  if (! ARError(ret, status)) {
	    RETVAL = entryId;
	  }
#ifndef WASTE_MEM
	  for (j=0; j<c; j++) {
	    FreeARValueStruct(&fieldList.fieldValueList[j].value, FALSE);
	  }
#endif
	merge_entry_end:;
#ifndef WASTE_MEM
	  free(fieldList.fieldValueList);
#endif
	merge_entry_exit:;
	}
	OUTPUT:
	RETVAL

###################################################
# NT (Notifier) ROUTINES
#

int
ars_NTInitializationClient()
        CODE:
        {
          NTStatusList status;
          int ret;

	  (void) ARError_reset();
          RETVAL = 0;
#if AR_EXPORT_VERSION < 3
          ret = NTInitializationClient(&status);
          if(!NTError(ret, status)) {
            RETVAL = 1;
          }
#else
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_DEPRECATED, "NTInitializationClient() is only available in ARS2.x");
#endif
        }
        OUTPUT:
        RETVAL


int 
ars_NTDeregisterClient(user, password, filename)
	char *		user
	char *		password
	char *		filename
	CODE:
	{
	  NTStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
#if AR_EXPORT_VERSION < 3
	  if(user && password && filename) {
	    ret = NTDeregisterClient(user, password, filename, &status);
	    if(!NTError(ret, status)) {
	      RETVAL = 1;
	    }
	  }
#else
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_DEPRECATED, "NTDeregisterClient() is only available in ARS2.x");
#endif
	}
	OUTPUT:
	RETVAL

int
ars_NTRegisterClient(user, password, filename)
	char *		user
	char *		password
	char *		filename
	CODE:
	{
	  NTStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
#if AR_EXPORT_VERSION < 3
	  if(user && password && filename) {
	    ret = NTRegisterClient(user, password, filename, &status);
	    if(!NTError(ret, status)) {
		RETVAL = 1;
	    }
	  }
#else
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_DEPRECATED, "NTRegisterClient() is only available in ARS2.x");
#endif
	}
	OUTPUT:
	RETVAL

int
ars_NTTerminationClient()
	CODE:
	{
	  NTStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
#if AR_EXPORT_VERSION < 3
	  ret = NTTerminationClient(&status);
	  if(!NTError(ret, status)) {
	    RETVAL = 1;
	  }
#else
	  (void) ARError_add(AR_RETURN_ERROR, AP_ERR_DEPRECATED, "NTTerminationClient() is only available in ARS2.x");
#endif
	}
	OUTPUT:
	RETVAL

int
ars_NTRegisterServer(serverHost, user, password, ...)
	char *		serverHost
	char *		user
	char *		password
	CODE:
	{
	  NTStatusList status;
	  int ret;
#if AR_EXPORT_VERSION < 3
	  (void) ARError_reset();
	  RETVAL = 0;
	  if(serverHost && user && password && items == 3) {
	    ret = NTRegisterServer(serverHost, user, password, &status);
	    if(!NTError(ret, status)) {
		RETVAL = 1;
	    }
	  } else {
	    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_USAGE, "usage: ars_NTRegisterServer(serverHost, user, password)");
	  }
#else
	  unsigned long clientPort;
	  unsigned int clientCommunication;
	  unsigned int protocol;
	  int multipleClients;

	  (void) ARError_reset();
	  RETVAL = 0;
          if (items < 4 || items > 7) {
	    (void) ARError_add(AR_RETURN_ERROR, AP_ERR_BAD_ARGS);
	  }
	  clientPort = (unsigned int)SvIV(ST(4));
	  if (items < 5) {
	    clientCommunication = 2;
	  } else {
	    clientCommunication = (unsigned int)SvIV(ST(5));
	  }
	  if (items < 6) {
	    protocol = 1;
	  } else {
	    protocol = (unsigned int)SvIV(ST(6));
	  }
	  if (items < 7) {
	    multipleClients = 1;
	  } else {
	    multipleClients = (unsigned int)SvIV(ST(1));
	  }
	  
	  if(clientCommunication == NT_CLIENT_COMMUNICATION_SOCKET) {
	    if(protocol == NT_PROTOCOL_TCP) {
	      ret = NTRegisterServer(serverHost, user, password, clientCommunication, clientPort, protocol, multipleClients, &status);
	      if(!NTError(ret, status)) {
		RETVAL = 1;
	      }
	    }
	  }
#endif
	}
	OUTPUT:
	RETVAL

int 
ars_NTTerminationServer()
	CODE:
	{
	 int ret;
	 NTStatusList status;

	 (void) ARError_reset();
	 RETVAL = 0;
	 ret = NTTerminationServer(&status);
	 if(!NTError(ret, status)) {
	   RETVAL = 1;
	 }
	}
	OUTPUT:
	RETVAL

int
ars_NTDeregisterServer(serverHost, user, password)
	char *		serverHost
	char *		user
	char *		password
	CODE:
	{
	 int ret;
	 NTStatusList status;

	 (void) ARError_reset();
	 RETVAL = 0; /* assume error */
	 if(serverHost && user && password) {
	    ret = NTDeregisterServer(serverHost, user, password, &status);
	    if(!NTError(ret, status)) {
		RETVAL = 1; /* success */
	    }
	 }
	}
	OUTPUT:
	RETVAL

void
ars_NTGetListServer()
	PPCODE:
	{
	  NTServerNameList serverList;
	  NTStatusList status;
	  int ret,i;

	  (void) ARError_reset();
	  ret = NTGetListServer(&serverList, &status);
	  if(!NTError(ret, status)) {
	     for(i=0; i<serverList.numItems; i++) {
	        XPUSHs(sv_2mortal(newSVpv(serverList.nameList[i], 0)));
	     }
#ifndef WASTE_MEM
	     FreeNTServerNameList(&serverList, FALSE);
#endif
	  }
	}

int
ars_NTInitializationServer()
	CODE:
	{
	  NTStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0; /* error */
	  ret = NTInitializationServer(&status);
	  if(!NTError(ret, status)) {
	     RETVAL = 1; /* success */
	  }
	}
	OUTPUT:
	RETVAL

int
ars_NTNotificationServer(serverHost, user, notifyText, notifyCode, notifyCodeText)
	char *		serverHost
	char *		user
	char *		notifyText
	int		notifyCode
	char *		notifyCodeText
	CODE:
	{
	  NTStatusList status;
	  int ret;

	  (void) ARError_reset();
	  RETVAL = 0;
	  if(serverHost && user && notifyText) {
	     ret = NTNotificationServer(serverHost, user, notifyText, notifyCode, notifyCodeText, &status);
	     if(!NTError(ret, status)) {
		RETVAL = 1;
	     }
	  }
	}
	OUTPUT:
	RETVAL

#
# Destructors for Blessed C structures
#

MODULE = ARS		PACKAGE = ARControlStructPtr

void
DESTROY(ctrl)
	ARControlStruct *	ctrl
	CODE:
	{
#ifndef WASTE_MEM
	  free(ctrl);
#endif
	}

MODULE = ARS		PACKAGE = ARQualifierStructPtr

void
DESTROY(qual)
	ARQualifierStruct *	qual
	CODE:
	{
#ifndef WASTE_MEM
	  FreeARQualifierStruct(qual, 1);
#endif
	}
