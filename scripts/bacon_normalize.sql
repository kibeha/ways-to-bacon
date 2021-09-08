/*
Assume tables raw_imdb_* have been created and loaded
*/

/*
Create normalized tables for the small file
*/

create table actors_small
as
select rownum as id, actor from (
   select distinct actor
   from raw_imdb_small
);

alter table actors_small add (
   constraint actors_small_pk primary key (id)
 , constraint actors_small_uq unique (actor)
);

--

create table movies_small
as
select rownum as id, movie from (
   select distinct movie
   from raw_imdb_small
);

alter table movies_small add (
   constraint movies_small_pk primary key (id)
 , constraint movies_small_uq unique (movie)
);

--

create table cast_members_small
as
select
   distinct -- only really needed for FULL file
   a.id as actor_id
 , m.id as movie_id
from raw_imdb_small imdb
join actors_small a
   on a.actor = imdb.actor
join movies_small m
   on m.movie = imdb.movie;

alter table cast_members_small add (
   constraint cast_members_small_fk_actors foreign key (actor_id) references actors_small (id)
 , constraint cast_members_small_fk_movies foreign key (movie_id) references movies_small (id)
 , constraint cast_members_small_pk primary key (actor_id, movie_id)
);

create unique index cast_members_small_uq_idx on cast_members_small (movie_id, actor_id);

--

create table co_actors_small (
   actor_id_1  number
 , actor_id_2  number
 , movies      blob check (movies is json)
);

insert into co_actors_small (
   actor_id_1
 , actor_id_2
 , movies
)
select
   cm1.actor_id as actor_id_1
 , cm2.actor_id as actor_id_2
 , json_arrayagg(cm1.movie_id returning blob) as movies
from cast_members_small cm1
join cast_members_small cm2
   on cm2.movie_id = cm1.movie_id
   and cm2.actor_id != cm1.actor_id
group by
   cm1.actor_id
 , cm2.actor_id;

commit;

alter table co_actors_small add (
   constraint co_actors_small_fk_actor_1 foreign key (actor_id_1) references actors_small (id)
 , constraint co_actors_small_fk_actor_2 foreign key (actor_id_2) references actors_small (id)
 , constraint co_actors_small_pk primary key (actor_id_1, actor_id_2)
);


select *
from actors_small actor
where actor.actor = 'Kevin Bacon (I)';


/*
Create normalized tables for the top250 file
*/

create table actors_top250
as
select rownum as id, actor from (
   select distinct actor
   from raw_imdb_top250
);

alter table actors_top250 add (
   constraint actors_top250_pk primary key (id)
 , constraint actors_top250_uq unique (actor)
);

--

create table movies_top250
as
select rownum as id, movie from (
   select distinct movie
   from raw_imdb_top250
);

alter table movies_top250 add (
   constraint movies_top250_pk primary key (id)
 , constraint movies_top250_uq unique (movie)
);

--

create table cast_members_top250
as
select
   distinct -- only really needed for FULL file
   a.id as actor_id
 , m.id as movie_id
from raw_imdb_top250 imdb
join actors_top250 a
   on a.actor = imdb.actor
join movies_top250 m
   on m.movie = imdb.movie;

alter table cast_members_top250 add (
   constraint cast_members_top250_fk_actors foreign key (actor_id) references actors_top250 (id)
 , constraint cast_members_top250_fk_movies foreign key (movie_id) references movies_top250 (id)
 , constraint cast_members_top250_pk primary key (actor_id, movie_id)
);

create unique index cast_members_top250_uq_idx on cast_members_top250 (movie_id, actor_id);

--

create table co_actors_top250 (
   actor_id_1  number
 , actor_id_2  number
 , movies      blob check (movies is json)
);

insert into co_actors_top250 (
   actor_id_1
 , actor_id_2
 , movies
)
select
   cm1.actor_id as actor_id_1
 , cm2.actor_id as actor_id_2
 , json_arrayagg(cm1.movie_id returning blob) as movies
from cast_members_top250 cm1
join cast_members_top250 cm2
   on cm2.movie_id = cm1.movie_id
   and cm2.actor_id != cm1.actor_id
group by
   cm1.actor_id
 , cm2.actor_id;

commit;

alter table co_actors_top250 add (
   constraint co_actors_top250_fk_actor_1 foreign key (actor_id_1) references actors_top250 (id)
 , constraint co_actors_top250_fk_actor_2 foreign key (actor_id_2) references actors_top250 (id)
 , constraint co_actors_top250_pk primary key (actor_id_1, actor_id_2)
);


select *
from actors_top250 actor
where actor.actor = 'Kevin Bacon (I)';


/*
Create normalized tables for the full file
*/

create table actors_full
as
select rownum as id, actor from (
   select distinct actor
   from raw_imdb_full
);

alter table actors_full add (
   constraint actors_full_pk primary key (id)
 , constraint actors_full_uq unique (actor)
);

--

create table movies_full
as
select rownum as id, movie from (
   select distinct movie
   from raw_imdb_full
);

alter table movies_full add (
   constraint movies_full_pk primary key (id)
 , constraint movies_full_uq unique (movie)
);

--

create table cast_members_full
as
select
   distinct -- only really needed for FULL file, as it contains duplicates
   a.id as actor_id
 , m.id as movie_id
from raw_imdb_full imdb
join actors_full a
   on a.actor = imdb.actor
join movies_full m
   on m.movie = imdb.movie;

alter table cast_members_full add (
   constraint cast_members_full_fk_actors foreign key (actor_id) references actors_full (id)
 , constraint cast_members_full_fk_movies foreign key (movie_id) references movies_full (id)
 , constraint cast_members_full_pk primary key (actor_id, movie_id)
);

create unique index cast_members_full_uq_idx on cast_members_full (movie_id, actor_id);

--

create table co_actors_full
as
select
   cm1.actor_id as actor_id_1
 , cm2.actor_id as actor_id_2
from cast_members_full cm1
join cast_members_full cm2
   on cm2.movie_id = cm1.movie_id
   and cm2.actor_id != cm1.actor_id
group by
   cm1.actor_id
 , cm2.actor_id;


alter table co_actors_full add (
   constraint co_actors_full_fk_actor_1 foreign key (actor_id_1) references actors_full (id)
 , constraint co_actors_full_fk_actor_2 foreign key (actor_id_2) references actors_full (id)
 , constraint co_actors_full_pk primary key (actor_id_1, actor_id_2)
);

/*
select count(*) from co_actors_full;

218525184
*/

select *
from actors_full actor
where actor.actor = 'Kevin Bacon (I)';

