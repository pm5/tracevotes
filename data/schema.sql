CREATE TYPE party as ENUM('DPP', 'KMT');

CREATE TABLE rates (
  city_county varchar(255) not null,
  township_city varchar(255) not null,
  village varchar(255) not null,
  year int not null,
  party party not null,
  received_votes int not null,
  issued_votes int not null,
  population int not null,
  rate real not null
);

COPY rates FROM '/app/data/president_rates.csv' WITH (FORMAT csv);
