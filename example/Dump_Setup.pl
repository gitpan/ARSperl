#!/usr/local/bin/perl
#
# EXAMPLE
#    Dump_Setup.pl
#
# DESCRIPTION
#    Log onto the server and export all schemas, filters, etc.
# 
# NOTES
#    This might require special permission for the username you login as
#
# AUTHOR
#    joel murphy
#
# 03/14/96
#

use ARS;

$perm = 0755;

($server,$username,$pass,$path) = @ARGV;
$path = "." if (!$path);
$c = ars_Login($server,$username,$pass);

@schema = ars_GetListSchema($c);
@active = ars_GetListActiveLink($c);
@filter = ars_GetListFilter($c);
@escal = ars_GetListEscalation($c);
@menu = ars_GetListCharMenu($c);
@admin_ext = ars_GetListAdminExtension($c);

# Warning! this might make several names map to the same file
sub name_to_path {
    my $name = shift;
    $name =~ s/ /_/g;
    $name =~ s/\//:/g;
    return $name;
}

if (! -d "$path/schema") {
    mkdir "$path/schema", $perm || die "can't create directory schema";
    mkdir "$path/schema/RCS", $perm || die "can't create directory schema";
}
foreach $schema (@schema) {
    $s = ars_Export($c,"","Schema",$schema);
    $schema = name_to_path($schema);
    open DUMP, "> $path/schema/$schema" || die "can't write file $path/schema/$schema";
    print DUMP $s;
    close DUMP;
}

if (! -d "$path/active") {
    mkdir "$path/active", $perm || die "can't create directory active";
    mkdir "$path/active/RCS", $perm || die "can't create directory active";
}
foreach $active (@active) {
    $a = ars_Export($c,"","Active_Link",$active);
    $active = name_to_path($active);
    open DUMP, "> $path/active/$active" || die "can't write file $path/active/$active";
    print DUMP $a;
    close DUMP;
}

if (! -d "$path/filter") {
    mkdir "$path/filter", $perm || die "can't create directory filter";
    mkdir "$path/filter/RCS", $perm || die "can't create directory filter";
}
foreach $filter (@filter) {
    $f = ars_Export($c,"","Filter",$filter);
    $filter = name_to_path($filter);
    open DUMP, "> $path/filter/$filter" || die "can't write file $path/filter/$filter";
    print DUMP $f;
    close DUMP;
}

if (! -d "$path/escalation") {
    mkdir "$path/escalation", $perm || die "can't create directory escalation";
    mkdir "$path/escalation/RCS", $perm || die "can't create directory escalation";
}
foreach $escal (@escal) {
    $e = ars_Export($c,"","Escalation",$escal);
    $escal = name_to_path($escal);
    open DUMP, "> $path/escalation/$escal" || die "can't write file $path/escalation/$escal";
    print DUMP $e;
    close DUMP;
}

if (! -d "$path/menu") {
    mkdir "$path/menu", $perm || die "can't create directory menu";
    mkdir "$path/menu/RCS", $perm || die "can't create directory menu";
}
foreach $menu (@menu) {
    $m = ars_Export($c,"","Char_Menu",$menu);
    $menu = name_to_path($menu);
    open DUMP, "> $path/menu/$menu" || die "can't write file $path/menu/$menu";
    print DUMP $m;
    close DUMP;
}

if (! -d "$path/admin_ext") {
    mkdir "$path/admin_ext", $perm || die "can't create directory admin_ext";
    mkdir "$path/admin_ext/RCS", $perm || die "can't create directory admin_ext";
}
foreach $admin_ext (@admin_ext) {
    $a = ars_Export($c,"","Admin_Ext",$admin_ext);
    $admin_ext = name_to_path($admin_ext);
    open DUMP, "> $path/admin_ext/$admin_ext" || die "can't write file $path/admin_ext/$admin_ext";
    print DUMP $a;
    close DUMP;
}
