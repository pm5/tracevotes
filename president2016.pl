#!/usr/bin/env perl -w

use v5.026;
use Text::CSV qw(csv);
use YAML::Dumper;
use Storable;
use utf8;

my $dumper = YAML::Dumper->new;

binmode STDOUT, ":encoding(utf-8)";

my $input = csv(in => "elctks_P1.csv", headers => "auto");

sub make_cities {
    if (-r "cities.store") {
        return retrieve("cities.store");
    }
    my $cities = {
        map { $_->{U0} . $_->{U1} => $_->{PLACE_NAME} }
            @{csv(in => "city.csv", headers => "auto")}
    };
    store $cities, "cities.store";
    $cities;
}

my $cities = make_cities();

my $districts = {
    map { $_->{U0} . $_->{U1} . $_->{DISTRICT} => $_->{PLACE_NAME} } @{csv(in => "districts.csv", headers => "auto")}
};

my $villages = {};

foreach (@{csv(in => "elbase_P1.csv", headers => "auto")}) {
    next if $_->{VILLAGE} eq "0000";
    $villages->{$_->{U0} . $_->{U1} . $_->{DISTRICT} . $_->{VILLAGE}} = $_->{PLACE_NAME};
}

my $votes = csv(in => "president.csv", headers => "auto");

my $output = [];

my %candidates = (
    "1" => "朱立倫",
    "2" => "蔡英文",
    "3" => "宋楚瑜",
);

#my $limit = 10;

foreach my $row (@$input) {
    next unless $row->{DISTRICT} ne "000" && $row->{VILLAGE} ne "0000";

    $row->{YEAR} = 2016;
    $row->{CANDIDATE} = $candidates{$row->{CANDIDATE_NUMBER}};
    $row->{AREA}
        = $cities->{$row->{U0} . $row->{U1}}
        . $districts->{$row->{U0} . $row->{U1} . $row->{DISTRICT}}
        . $villages->{$row->{U0} . $row->{U1} . $row->{DISTRICT} . $row->{VILLAGE}};

    delete $row->{U0};
    delete $row->{U1};
    delete $row->{U2};
    delete $row->{DISTRICT};
    delete $row->{VILLAGE};
    delete $row->{BOOTH};
    delete $row->{ELECTED};

    #say $dumper->dump($row);
    #exit -1 if $limit <= 0;
    #--$limit;

    push @$votes, $row;
}

my $headers = [qw(YEAR AREA CANDIDATE CANDIDATE_NUMBER VOTES RATE)];

csv(in => $votes, out => "president.csv", sep_char => ",", encoding => "utf-8", headers => $headers);
