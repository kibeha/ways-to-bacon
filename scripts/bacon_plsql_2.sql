/*
Assume normalized tables have been created and loaded

Modified BFS PL/SQL solution by kibeha to query co_actors_* tables instead of PL/SQL collection
*/

/*
Types for table function
*/

create or replace type shortest_path as object (
   actor_id       number
 , bacon#         number
 , connect_path   clob
)
/
create or replace type shortest_paths as table of shortest_path
/


/*
PL/SQL Breadth-First on small file
*/

create or replace function bacon2_small(
   start_actor    actors_small.id%type
)
   return shortest_paths
as
  type   found_type is table of boolean   index by pls_integer;
  found  found_type ;
  result shortest_paths := shortest_paths();
  seq    pls_integer;
begin
  result.extend;
  result(1) := shortest_path(start_actor, 0, to_clob(start_actor));
  found(start_actor) := null;
  seq := 1;
  
  while result.exists(seq) loop
    exit when result(seq).bacon# >= 6;   -- "Six Degrees of Kevin Bacon"
    for neighbor in (
      select
         ca.actor_id_2
      from co_actors_small ca
      where ca.actor_id_1 = result(seq).actor_id
    ) loop
      if not found.exists(neighbor.actor_id_2) then
        result.extend;
        result(result.last) := shortest_path(neighbor.actor_id_2, result(seq).bacon# + 1, result(seq).connect_path || '->' || neighbor.actor_id_2);
        found(neighbor.actor_id_2) := null;
      end if;
    end loop;
    seq := seq + 1;
  end loop;
  return result;
end bacon2_small;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_small a1
cross apply bacon2_small(a1.id) bs
join actors_small a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)'
order by bs.bacon# desc, bs.actor_id;

-- 161 rows average 0.15 seconds

/*
PL/SQL Breadth-First on top250 file
*/

create or replace function bacon2_top250(
   start_actor    actors_top250.id%type
)
   return shortest_paths
as
  type   found_type is table of boolean   index by pls_integer;
  found  found_type ;
  result shortest_paths := shortest_paths();
  seq    pls_integer;
begin
  result.extend;
  result(1) := shortest_path(start_actor, 0, to_clob(start_actor));
  found(start_actor) := null;
  seq := 1;
  
  while result.exists(seq) loop
    exit when result(seq).bacon# >= 6;   -- "Six Degrees of Kevin Bacon"
    for neighbor in (
      select
         ca.actor_id_2
      from co_actors_top250 ca
      where ca.actor_id_1 = result(seq).actor_id
    ) loop
      if not found.exists(neighbor.actor_id_2) then
        result.extend;
        result(result.last) := shortest_path(neighbor.actor_id_2, result(seq).bacon# + 1, result(seq).connect_path || '->' || neighbor.actor_id_2);
        found(neighbor.actor_id_2) := null;
      end if;
    end loop;
    seq := seq + 1;
  end loop;
  return result;
end bacon2_top250;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_top250 a1
cross apply bacon2_top250(a1.id) bs
join actors_top250 a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)'
order by bs.bacon# desc, bs.actor_id;

-- 11803 rows average 8 seconds


/*
PL/SQL Breadth-First on full file
*/

create or replace function bacon2_full(
   start_actor    actors_full.id%type
)
   return shortest_paths
as
  type   found_type is table of boolean   index by pls_integer;
  found  found_type ;
  result shortest_paths := shortest_paths();
  seq    pls_integer;
begin
  result.extend;
  result(1) := shortest_path(start_actor, 0, to_clob(start_actor));
  found(start_actor) := null;
  seq := 1;
  
  while result.exists(seq) loop
    exit when result(seq).bacon# >= 6;   -- "Six Degrees of Kevin Bacon"
    for neighbor in (
      select
         ca.actor_id_2
      from co_actors_full ca
      where ca.actor_id_1 = result(seq).actor_id
    ) loop
      if not found.exists(neighbor.actor_id_2) then
        result.extend;
        result(result.last) := shortest_path(neighbor.actor_id_2, result(seq).bacon# + 1, result(seq).connect_path || '->' || neighbor.actor_id_2);
        found(neighbor.actor_id_2) := null;
      end if;
    end loop;
    seq := seq + 1;
  end loop;
  return result;
end bacon2_full;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_full a1
cross apply bacon2_full(a1.id) bs
join actors_full a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)'
order by bs.bacon# desc, bs.actor_id;

-- ORA-04036: PGA memory used by the instance exceeds PGA_AGGREGATE_LIMIT
