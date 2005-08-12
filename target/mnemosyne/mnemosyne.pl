#!/usr/bin/perl
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: target/mnemosyne/mnemosyne.pl
# Copyright (C) 2004 - 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

use warnings;
use strict;

use constant {ALL => 0, ASK => 1, CHOICE => 2 };
%::FOLDER=();
%::MODULE=();

sub tgt_mnemosyne_parser {
	my ($field,$file,$default) = @_;
	my $output;

	open(my $FILE,'<',$file);
	while(<$FILE>) {
		/^#$field/ && do {
			/^\#$field: (.*)$/i;
			$output=$1;
			};
		}
	close($FILE);

	$output=$default unless $output;
	return $output;
}


sub scandir {
	my ($pkgseldir,$prefix) = @_;
	my %current=('location', $pkgseldir, 'var', "CFGTEMP_$prefix");

	# $current{desc,var} for sub-pkgsel dirs
	if ($pkgseldir ne $::ROOT) {
		my ($relative,$dirvar,$dirname);
		$_ = $pkgseldir;
		$relative = (m/^$::ROOT\/(.*)/i)[0];

		$dirvar =  "CFGTEMP_$prefix\_$relative";
		$dirvar =~ tr,a-z\/,A-Z_,;

		$dirname=$relative;
		$dirname=~ s/.*\///g;

		$current{desc} = $dirname;
		$current{var}  = $dirvar;
	}
	$::FOLDER{$current{var}} = \%current;

	{
	# make scandir recursive
	my @subdirs;
	opendir(my $DIR, $pkgseldir);
	foreach( grep { ! /^\./ } sort readdir($DIR) ) {
		$_ = "$pkgseldir/$_";
		if ( -d $_ ) {
			my $subdir = scandir($_,$prefix);
			push @subdirs,$subdir;
		} else {
			scanoption($_,$prefix);
		}
	}
        closedir $DIR;
	$current{subdirs} = \@subdirs;
	return $current{var};
	}

}

sub scanoption {
	my ($file,$prefix)=@_;
	my %current;

	#keep it compiling
	#my ($x,$y,$desc,@forced,@deps,$conffile,@pkgselfiles);
	
	# this defines dir,var0,option and kind acording to the following format.
	# $dir/[$prio-]$var[$option].$kind
	do {
		my ($dir,$var0,$var,$option,$kind);
		m/^(.*)\/(\d+-)?([^\.]*).?([^\.]*)?\.([^\/\.]*)/i;
		($dir,$var0,$option,$kind) = ($1,$3,$4,$5);

		if ($kind eq 'choice') { $current{kind} = CHOICE; }
		elsif ($kind eq 'all') { $current{kind} = ALL; }
		elsif ($kind eq 'ask') { $current{kind} = ASK; }
		else { return; }
	
	} for $file;


	return;

=for reference
	# external data: configin rulesin prefix 
	# global variables: onchoice render

	# var name and description
	SWITCH: for ($kind) {
		/^choice$/ && do {
			# new choice?

		#	$onchoice=0 if ($onchoice && ($onchoice cmp $var) != 0);

			($x = $var0) =~ s/_/ /g;
			($y = $option) =~ s/_/ /g;
			$desc=tgt_mnemosyne_parser('Description',$file,"$x ($y)");

		#	if ( ! $onchoice ) {
		#		$onchoice=$var;

				print $::RULES	"\tCFGTEMP_TRG_$prefix\_$var=0\n";
				print $::CONFIG	"\tif [ \"\$CFGTEMP_TRG_$prefix\_$var\" == 1 ]; then\n";
				print $::CONFIG	"\t\tchoice SDECFG_TRG_$prefix\_$var \${CFGTEMP_TRG_$prefix\_$var\_DEFAULT:-$option} \${CFGTEMP_TRG_$prefix\_$var\_LIST}\n";
				print $::CONFIG "\tfi\n";
		#		}
			last SWITCH; };
		/^(?:ask|all )$/ && do {
			$var=tgt_mnemosyne_parser('Variable',$file,$var);
			($x = $var0) =~ s/_/ /g;
			$desc=tgt_mnemosyne_parser('Description',$file,$x);
		#	$onchoice=0;
			last SWITCH; };
		do { return; };
		}
	$var="SDECFG_TRG_$prefix\_$var";

	# dependencies
	# NOTE: don't use spaces on the pkgsel file, only to delimite different dependencies
	for ( split (/\s/,tgt_mnemosyne_parser('Dependencies',$file,)) ) {
		$_="SDECFG_TRG_$prefix\_$_" unless /^SDECFG/;

		if (/=/) {
			m/(.*)(==|!=|=)(.*)/i;
			$_="\"\$$1\" $2 $3";
			}
		else {
			$_="\"\$$_\" == '1'";
			}

		push @deps,$_;
		}

	# forced options
	for ( split (/\s/,tgt_mnemosyne_parser('Forced',$file,)) ) {
		$_="SDECFG_TRG_$prefix\_$_" unless /^SDECFG/;

		$_="$_='1'" unless /=/;
		push @forced,$_;
	}

	# config script file
	$_=$file;
	/^(.*).$kind/i;
	$conffile="$1\.conf" if ( -f "$1\.conf" );

	print "($dir,$var0,$var,$option,$kind)\n";
	# pkgsel files
	@pkgselfiles=($file);
	print "$file ($kind)\n";
	if ( $kind eq 'choice' ) {
		print "$file is a choice.\n";
=for comment
		for x in $( tgt_mnemosyne_parser Imply $file ); do
			y=`echo $dir/*$var0.$x.choice`
			if [ -f "$y" ]; then
				pkgselfiles="$pkgselfiles $y"
			fi
		done
#=cut
	}

#=for comment
	# content
	case "$kind" in
		ask)	val=$( tgt_mnemosyne_parser Default $file 0 )	;;
		choice)	val=$( tgt_mnemosyne_parser Default $file )	;;
		*)	val=1	;;
	esac

	#
	# output to rules file
	#
	{
	if [ "$deps" -a "$kind" != "choice" ]; then
		echo "CFGTEMP${var#SDECFG}=\${CFGTEMP${var#SDECFG}:-0}"
	fi

	# dependencies
	[ "$deps" ] && echo "if [ $deps ]; then"
	echo -e "  CFGTEMP${var#SDECFG}=1"

	# choice option
	if [ "$kind" == "choice" ]; then
		echo "  var_append CFGTEMP${var#SDECFG}_LIST ' ' '$option ${desc// /_}'"
		if [ "$val" ]; then
			echo "  CFGTEMP${var#SDECFG}_DEFAULT=$val"
		fi
	fi

	# forced
	if [ "$forced" ]; then
		if [ "$kind" == "choice" ]; then
			if [ "$val" ]; then
				cat <<-EOT
				  if [ "\${$var:-$val}" == "$option" ]; then
				EOT
			else
				cat <<-EOT
				  if [ "\$$var" == "$option" ]; then
				EOT
			fi
		elif [ "$val" ]; then
			cat <<-EOT
			  if [ "\${$var:-$val}" == 1 ]; then
			EOT
		else
			cat <<-EOT
			  if [ "\$$var" == 1 ]; then
			EOT
		fi

		for x in $forced; do
			echo "    $x"
		done
		echo "  fi"
	fi

	[ "$deps" ] && echo "fi"
	} >> $rulesin


	#
	# output to config file
	#
	{
	echo "if [ \$CFGTEMP${var#SDECFG} == 1 ]; then"
	
	case "$kind" in
		ask)	echo "   bool '$desc' $var $val"	;;
		choice)	true	;;
		*)	echo "   $var=1"	;;
	esac

	if [ "$kind" == "choice" ]; then
		cat <<-EOT
		  if [ "\$$var" == "$option" ]; then
		EOT
	else
		cat <<-EOT
		   if [ "\$$var" == 1 ]; then
		EOT
	fi
	cat <<-EOT
	      var_append CFGTEMP_TRG_${prefix}_PKGLST ' ' "$pkgselfiles"
	EOT

	# conffiles
	for x in $conffile; do
		echo "      . $x"
	done

	cat <<-EOT
	   fi
	fi
	EOT
	} >> $configin

	if [ "$deps" ]; then
		case "$kind" in
			ask|choice)
				# TODO: add rule: this directory will be shown if these deps are meet
				true	;;
		esac
	else
		case "$kind" in
			ask)	render=1	;;
			choice)	render=1
				# TODO: add rule: always display this choice
				;;
		esac
	fi
#=cut
}

sub trg_mnemosyne_filter {
=for comment
	echo "# generated for $SDECFG_TARGET target"
	pkgsel_init
	echo '{ $1="O"; }'
	for file; do
		pkgsel_parse < $file
	done
	pkgsel_finish
=cut
}

# print the content of a hash
sub printhash {
	my ($hash,$offset) = @_;
	for (sort keys %{ $hash }) {
		print "$offset$_";
		if (ref($hash->{$_}) eq '') {
			print ": $hash->{$_}\n";
			}
		elsif (ref($hash->{$_}) eq 'HASH') {
			print ":\n";
			printhash( $hash->{$_}, "$offset\t" );
			}
		elsif (ref($hash->{$_}) eq 'ARRAY') {
			print ": (";
			print join (',', @{ $hash->{$_} });
			print ")\n";
			}
		else {
			print ": -> ".ref($hash->{$_})."\n";
			}
	}
}

if ($#ARGV != 3) {
	print "Usage mnemosyne.pl: <pkgseldir> <prefix> <configfile> <rulesfile>\n";
	exit (1);
	}

$::ROOT=$ARGV[0];
open($::CONFIG,'>',$ARGV[2]);
open($::RULES,'>',$ARGV[3]);
scandir($ARGV[0],$ARGV[1]);
printhash(\%::FOLDER,'');
printhash(\%::MODULE,'');
close($_) for ($::CONFIG,$::RULES);
