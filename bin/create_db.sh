CREATE TYPE party as ENUM('DPP', 'KMT');

CREATE TABLE rates (
  city_county varchar(255) not null,
  township_city varchar(255) not null,
  village varchar(255) not null,
  party party not null,
  year int not null,
  received_votes int not null,
  issued_votes int not null,
  rate real not null
);

CREATE TABLE dpp_to_kmt_rates (
  city_county varchar(255) not null,
  township_city varchar(255) not null,
  village varchar(255) not null,
  year int not null,
  dpp_to_kmt_rate real not null
);

COPY rates FROM '/app/data/president_rates.csv' WITH (FORMAT csv);
