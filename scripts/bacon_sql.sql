/*
Assume normalized tables have been created and loaded

Adapted from Mathguy CTE solution on forums:

https://community.oracle.com/tech/developers/discussion/comment/16797236/#Comment_16797236
*/

/*
Collection to store visited actors
*/

create or replace type id_list as table of number
/


/*
Recursive subquery factoring on small file
*/

with recursor (
   actor_id, bacon#, connect_path, all_found, rn
) as (
   select
      actor.id
    , 0
    , to_clob(actor.id)
    , id_list(actor.id)
    , 1
   from actors_small actor
   where actor.actor = 'Kevin Bacon (I)'
   --
   union all
   --
   select
      ca.actor_id_2
    , r.bacon# + 1
    , r.connect_path || '->' || to_char(ca.actor_id_2)
    , r.all_found multiset union all cast(collect(ca.actor_id_2) over () as id_list)
    , row_number() over (partition by ca.actor_id_2 order by null)
   from recursor r
   join co_actors_small ca
      on ca.actor_id_1 = r.actor_id
      and not ca.actor_id_2 member of r.all_found
   where r.rn = 1
   and   r.bacon# < 6   -- "Six Degrees of Kevin Bacon"
)
   cycle actor_id set is_cycle to 'Y' default 'N'
select
   r.actor_id
 , a.actor
 , r.bacon#
 , r.connect_path
from recursor r
join actors_small a
   on a.id = r.actor_id
where r.rn = 1
order by r.bacon# desc, r.actor_id;



/*
Recursive subquery factoring on top250 file

Needs lots of temp or you get ORA-01652: unable to extend temp segment by 128 in tablespace TEMP
*/

with recursor (
   actor_id, bacon#, connect_path, all_found, rn
) as (
   select
      actor.id
    , 0
    , to_clob(actor.id)
    , id_list(actor.id)
    , 1
   from actors_top250 actor
   where actor.actor = 'Kevin Bacon (I)'
   --
   union all
   --
   select
      ca.actor_id_2
    , r.bacon# + 1
    , r.connect_path || '->' || to_char(ca.actor_id_2)
    , r.all_found multiset union all cast(collect(ca.actor_id_2) over () as id_list)
    , row_number() over (partition by ca.actor_id_2 order by null)
   from recursor r
   join co_actors_top250 ca
      on ca.actor_id_1 = r.actor_id
      and not ca.actor_id_2 member of r.all_found
   where r.rn = 1
   and   r.bacon# < 6   -- "Six Degrees of Kevin Bacon"
)
   cycle actor_id set is_cycle to 'Y' default 'N'
select
   r.actor_id
 , a.actor
 , r.bacon#
 , r.connect_path
from recursor r
join actors_top250 a
   on a.id = r.actor_id
where r.rn = 1
order by r.bacon# desc, r.actor_id;



/*
Recursive subquery factoring on full file

Do not try this!
*/

with recursor (
   actor_id, bacon#, connect_path, all_found, rn
) as (
   select
      actor.id
    , 0
    , to_clob(actor.id)
    , id_list(actor.id)
    , 1
   from actors_full actor
   where actor.actor = 'Kevin Bacon (I)'
   --
   union all
   --
   select
      ca.actor_id_2
    , r.bacon# + 1
    , r.connect_path || '->' || to_char(ca.actor_id_2)
    , r.all_found multiset union all cast(collect(ca.actor_id_2) over () as id_list)
    , row_number() over (partition by ca.actor_id_2 order by null)
   from recursor r
   join co_actors_full ca
      on ca.actor_id_1 = r.actor_id
      and not ca.actor_id_2 member of r.all_found
   where r.rn = 1
   and   r.bacon# < 6   -- "Six Degrees of Kevin Bacon"
)
   cycle actor_id set is_cycle to 'Y' default 'N'
select
   r.actor_id
 , a.actor
 , r.bacon#
 , r.connect_path
from recursor r
join actors_full a
   on a.id = r.actor_id
where r.rn = 1
order by r.bacon# desc, r.actor_id;

-- Didn't even try
