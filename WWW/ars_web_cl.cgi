#!/utiloss/bin/perl5.002
#
# $Header: /u1/project/ARSperl/ARSperl/WWW/RCS/ars_web_cl.cgi,v 1.1 1996/11/21 19:58:17 jcmurphy Exp $
#
#    ars_web_cl.cgi - A Web Client for ARS2.0
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
#
# $Log: ars_web_cl.cgi,v $
# Revision 1.1  1996/11/21 19:58:17  jcmurphy
# Initial revision
#
#

use Socket;
use FileHandle;
require 5.002;
require "cgi-lib.pl";

$SOCKET_DIR = "/tmp/ars_web_socket";
$SESS_SERVER = "./ars_web_serv";

sub do_it {
    $input{browser_host} = $ENV{REMOTE_HOST};
    $input{ident} = $ENV{REMOTE_IDENT};
    
    socket(SOCK, PF_UNIX, SOCK_STREAM, 0) || die "socket: $!";
    $uaddr = sockaddr_un("$SOCKET_DIR/$Socket");
    connect(SOCK, $uaddr) || die "connect: $!";
    SOCK->autoflush(1);
    @keys = keys %input;
    (print SOCK scalar(@keys)."\n") || die "print";
    foreach $key (@keys) {
	(print SOCK "$key\n") || die "print";
	(print SOCK length($input{$key})."\n") || die "print";
	(print SOCK $input{$key}) || die "print";
    }
    while (<SOCK>) {
	print;
    }
    exit;
}

if (ReadParse(*input)) {
    $ENV{REMOTE_HOST} =~ s/\'//;
    $ENV{REMOTE_IDENT} =~ s/\'//;
    $Socket = $input{socket};    
    do_it();
} else {
    # Spawn off a new server for this session
    $Socket = open(SERV, "-|");
    
    if ($Socket) {
	# fetch authentication key from server
	($Auth) = <SERV>;
	chomp($Auth);
	close(SERV) || die "can't spawn server!";
    } else {
	exec($SESS_SERVER, $ENV{REMOTE_HOST}, $ENV{REMOTE_IDENT}) ||
	    die "can't spawn server!";
    }
    $input{key} = $Auth;
    do_it();
}
