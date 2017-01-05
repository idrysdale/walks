CREATE TABLE activities (
  id integer,
  name character varying(128),
  started_at timestamp without time zone,
  course decimal[]
);

CREATE UNIQUE INDEX activities_index
ON activities (id);

CREATE TABLE hills (
  id serial,
  name character varying(128),
  coordinates decimal ARRAY[2],
  absolute_height integer,
  grid_ref character varying(8),
  url character varying(128)
);

CREATE UNIQUE INDEX hills_index
ON hills (id);

CREATE TABLE activities_hills (
  id serial,
  activity_id integer references activities(id),
  hill_id integer references hills(id)
);

CREATE UNIQUE INDEX activities_hills_index
ON activities_hills (id);
