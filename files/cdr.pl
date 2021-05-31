#!/usr/bin/perl
use strict;
use warnings;
use CGI::Carp 'fatalsToBrowser';
use CGI qw(-debug);
use CGI;
use DBI;
use Data::Dump qw(dump);
$|++;
my $q = CGI->new;
my $raw_cdr = $q->param('cdr');
my @all_fields = qw(caller_id_name caller_id_number
destination_number context start_stamp answer_stamp end_stamp
duration hangup_cause uuid read_codec write_codec media_bytes);
my @fields;
my @values;
my @temp;
foreach my $field (@all_fields) {
next unless $raw_cdr =~ m/$field>(.*?)</;
push @fields, $field;
my $t1 = $1;
push @values, "'" . urldecode($t1) . "'";
push @temp, "" .  urldecode($t1) . "";
}
my $path = join('','/usr/local/freeswitch/recordings/', $temp[9], '.wav');
push @values,"'" .  $path . "'";
push @fields, 'audio_record';
my $cdr_line;

my $query = sprintf(
"INSERT INTO %s (%s) VALUES (%s);",
'cdr', join(',', @fields), join(',', @values)
);
my $db = DBI->connect('DBI:PgPP:dbname=freeswitch;host=127.0.0.1',
'postgres', '1');
$db->do($query);
print $q->header();
sub urldecode {
my $url = shift;
$url =~ s/%([a-fA-F0-9]{2,2})/chr(hex($1))/eg;
return $url;
}
