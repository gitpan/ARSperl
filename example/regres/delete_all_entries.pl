#!/usr/local/bin/perl
#
# $Header$
#
# NAME
#   delete_all_entries.pl
#
# DESCRIPTION
#   delete all entries in the test schema.

use ARS;

require "./config.pl";

($S, $U, $P) = (shift, shift, shift);
($ctrl = ars_Login($S, $U, $P)) ||
    die "Login: $ars_errstr";
($qual = ars_LoadQualifier($ctrl, $SCHEMA, "(1 = 1)")) ||
    die "LoadQualifier: $ars_errstr";
(%entries = ars_GetListEntry($ctrl, $SCHEMA, $qual, 0)) ||
    die "GetListEntries: $ars_errstr";
foreach $entry_id (keys %entries) {
    print "$entry_id\n";
    if(ars_DeleteEntry($ctrl, $SCHEMA, $entry_id) == -1) {
	die "DeletEntry: $ars_errstr";
    }
}
ars_Logoff($ctrl);
exit(0);
