#!/usr/bin/env perl
use strict;
use warnings;
use 5.12.0;
use iCal::Parser;
use utf8;
use JSON;
use Clone qw/ clone /;
use Try::Tiny;
use Encode;
use List::Util qw/ max /;
use Web::Scraper;
use LWP::Simple;
use Digest::CRC qw/ crc16 /;

my %icals = (
    "講堂" => "http://www.google.com/calendar/ical/perlassociation.org_ua20j663bsirsk1dl577n43lns%40group.calendar.google.com/public/basic.ics",
    "百年記念館フェライト会議室" => "http://www.google.com/calendar/ical/perlassociation.org_rmkjj22qgrm2ivq0220of7p2f0%40group.calendar.google.com/public/basic.ics",
    "蔵前会館ローヤルブルーホール" => "http://www.google.com/calendar/ical/perlassociation.org_s67a3g2m5i1es2ite3i8hdgcng%40group.calendar.google.com/public/basic.ics",
);
my $result     = {};
my $timetables = [];
$result->{"ja"} = {
    "timetables" => $timetables,
    "rooms"      => [ keys %icals ],
};
my $ical_cache = {};
my $code = 0;
my $last_modified = DateTime->new( year => 2010, month => 9, day => 8, time_zone => "local" );
my $scraper = scraper {
    process '//div[@class="description"]//tr[4]/td[2]', summary => "TEXT";
};
for my $day (14, 15, 16) {
    my $sessions  = [];
    my $timetable = { day => "2010/10/$day", sessions => $sessions };
    for my $room ( keys %icals ) {
        my $ical = $ical_cache->{$room} ||= get( $icals{$room} );
        my $data = iCal::Parser->new->parse_strings($ical)->{events};
        my $events = $data->{2010}->{10}->{$day};
        for my $uid ( keys %$events ) {
            my $e = $events->{$uid};
            my ($title, $speaker)
                = ($e->{SUMMARY} =~ /^(.*) - (.*)$/);
            my $summary = { summary => "" };
            if ( $e->{DESCRIPTION} =~ /^http\:/ ) {
                my $uri = URI->new( $e->{DESCRIPTION} );
                warn "scrape from $uri\n";
                try { $summary = $scraper->scrape($uri) };
                $summary->{summary} .= "\n\n$uri";
                sleep 1;
            }
            push @{$sessions}, {
                speakers => [ { name => $speaker // "" } ],
                title    => $title // $e->{SUMMARY},
                start_at => $e->{DTSTART}->strftime("%H:%M"),
                end_at   => $e->{DTEND}->strftime("%H:%M"),
                room     => $room,
                code     => crc16( $e->{DESCRIPTION} ) . "",
                %$summary,
            };
            $last_modified = max( $e->{DTSTAMP}, $last_modified );
        }
    }
    $sessions = [ sort { $a->{start_at} cmp $b->{start_at} } @$sessions ];
    $timetable->{"sessions"} = $sessions;
    push @{$timetables}, $timetable;
}

$result->{"en"} = clone $result->{"ja"};
$result->{"updated_at"} = $last_modified->strftime("%Y-%m-%d %H:%M:%S %z");
say encode_utf8( JSON->new->encode($result) );
