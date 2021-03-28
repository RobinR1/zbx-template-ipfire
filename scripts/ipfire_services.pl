#!/usr/bin/perl

use strict;

# enable only the following on debugging purpose
# use warnings;

# Maps a nice printable name to the changing part of the pid file, which
# is also the name of the program
my %servicenames =(
        'DHCP Server' => 'dhcpd',
        'Web Server' => 'httpd',
        'CRON Server' => 'fcron',
        'DNS Proxy Server' => 'unbound',
        'Logging Server' => 'syslogd',
        'Kernel Logging Server' => 'klogd',
        'NTP Server' => 'ntpd',
        'Secure Shell Server' => 'sshd',
        'VPN' => 'charon',
        'Web Proxy' => 'squid',
        'Intrusion Detection System' => 'suricata',
        'OpenVPN' => 'openvpn'
);

# Hash to overwrite the process name of a process if it differs from the launch command.
my %overwrite_exename_hash = (
        "suricata" => "Suricata-Main"
);

my $first = 1;

print "[";

# Built-in services
my $key = '';
foreach $key (sort keys %servicenames){
	print "," if not $first;
	$first = 0;

	print "{";
	print "\"service\":\"$key\",";

	my $shortname = $servicenames{$key};
	print &servicestats($shortname);
	
	print "}";
}

# Generate list of installed addon pak's
my @pak = `find /opt/pakfire/db/installed/meta-* 2>/dev/null | cut -d"-" -f2`;
foreach (@pak){
	chomp($_);

	# Check which of the paks are services
	my @svc = `find /etc/init.d/$_ 2>/dev/null | cut -d"/" -f4`;
	foreach (@svc){
		# blacklist some packages
		#
		# alsa has trouble with the volume saving and was not really stopped
		# mdadm should not stopped with webif because this could crash the system
		#
		chomp($_);
		if ( $_ eq 'squid' ) {
			next;
		}
		if ( ($_ ne "alsa") && ($_ ne "mdadm") ) {
			print ",";
			print "{";

			print "\"service\":\"Addon: $_\",";
			print "\"servicename\":\"$_\",";

			my $onboot = isautorun($_);
			print "\"onboot\":$onboot,";

			print &addonservicestats($_);

			print "}";
		}
	}
}	

print "]";

sub servicestats{
	my $cmd = $_[0];
	my $status = "\"servicename\":\"$cmd\",\"state\":\"0\"";
	my $pid = '';
	my $testcmd = '';
        my $exename;
        my $memory;


	$cmd =~ /(^[a-z]+)/;
	
	# Check if the exename needs to be overwritten.
        # This happens if the expected process name string
        # differs from the real one. This may happened if
        # a service uses multiple processes or threads.
        if (exists($overwrite_exename_hash{$cmd})) {
                # Grab the string which will be reported by
                # the process from the corresponding hash.
                $exename = $overwrite_exename_hash{$1};
        } else {
                # Directly expect the launched command as
                # process name.
                $exename = $1;
        }
	
	if (open(FILE, "/var/run/${cmd}.pid")){
                $pid = <FILE>; chomp $pid;
                close FILE;
                if (open(FILE, "/proc/${pid}/status")){
                        while (<FILE>){
                                if (/^Name:\W+(.*)/) {
                                        $testcmd = $1;
                                }
                        }
                        close FILE;
                }
                if (open(FILE, "/proc/${pid}/status")) {
                        while (<FILE>) {
                                my ($key, $val) = split(":", $_, 2);
                                if ($key eq 'VmRSS') {
					$val =~ /\s*([0-9]*)\s+kB/;
					# Convert kB to B
                                        $memory = $1*1024;
                                        last;
                                }
                        }
                        close(FILE);
                }
                if ($testcmd =~ /$exename/){
			$status = "\"servicename\":\"$cmd\",\"state\":1,\"pid\":$pid,\"memory\":$memory";
		}
        }
        return $status;
}

sub isautorun{
        my $cmd = $_[0];
        my $status = "0";
        my $init = `find /etc/rc.d/rc3.d/S??${cmd} 2>/dev/null`;
        chomp ($init);
        if ($init ne ''){
                $status = "1";
        }
        $init = `find /etc/rc.d/rc3.d/off/S??${cmd} 2>/dev/null`;
        chomp ($init);
        if ($init ne ''){
                $status = "0";
        }

        return $status;
}

sub addonservicestats{
        my $cmd = $_[0];
        my $status = "0";
        my $pid = '';
        my $testcmd = '';
        my $exename;
        my @memory = (0);

        $testcmd = `sudo /usr/local/bin/addonctrl $_ status 2>/dev/null`;

        if ( $testcmd =~ /is\ running/ && $testcmd !~ /is\ not\ running/){
                $status = "\"state\":1";

                $testcmd =~ s/.* //gi;
                $testcmd =~ s/[a-z_]//gi;
                $testcmd =~ s/\[[0-1]\;[0-9]+//gi;
                $testcmd =~ s/[\(\)\.]//gi;
                $testcmd =~ s/  //gi;
                $testcmd =~ s///gi;

                my @pid = split(/\s/,$testcmd);
                $status .=",\"pid\":\"$pid[0]\"";

                my $memory = 0;

                foreach (@pid){
                        chomp($_);
                        if (open(FILE, "/proc/$_/statm")){
                                my $temp = <FILE>;
                                @memory = split(/ /,$temp);
                        }
                        $memory+=$memory[0];
                }
		$memory*=1024;
                $status .=",\"memory\":$memory";
        }else{
                $status = "\"state\":0";
        }
        return $status;
}
