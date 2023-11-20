/*
Assume normalized tables have been created and loaded

Modification of the modified BFS PL/SQL solution by kibeha - modified to reduce PGA by piping output and cleaning collection

This version *without* the connect_path to save even more memory
*/

/*
Types for table function
*/

create or replace type shortest_path_3b as object (
   actor_id       number
 , bacon#         number
)
/
create or replace type shortest_paths_3b as table of shortest_path_3b
/


/*
PL/SQL Breadth-First on small file
*/

create or replace function bacon3b_small(
   start_actor    actors_small.id%type
)
   return shortest_paths_3b pipelined
as
  type   found_type is table of boolean   index by pls_integer;
  found  found_type ;
  result shortest_paths_3b := shortest_paths_3b();
  seq    pls_integer;
begin
  result.extend;
  result(1) := shortest_path_3b(start_actor, 0);
  found(start_actor) := null;
  seq := 1;
  
  while result.exists(seq) loop
    exit when result(seq).bacon# > 6;   -- "Six Degrees of Kevin Bacon"
    for neighbor in (
      select
         ca.actor_id_2
      from co_actors_small ca
      where ca.actor_id_1 = result(seq).actor_id
    ) loop
      if not found.exists(neighbor.actor_id_2) then
        result.extend;
        result(result.last) := shortest_path_3b(neighbor.actor_id_2, result(seq).bacon# + 1);
        found(neighbor.actor_id_2) := null;
      end if;
    end loop;
    pipe row (result(seq));
    result.delete(seq);
    seq := seq + 1;
  end loop;
end bacon3b_small;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
from actors_small a1
cross apply bacon3b_small(a1.id) bs
join actors_small a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)'
order by bs.bacon# desc, bs.actor_id;


/*
PL/SQL Breadth-First on top250 file
*/

create or replace function bacon3b_top250(
   start_actor    actors_top250.id%type
)
   return shortest_paths_3b pipelined
as
  type   found_type is table of boolean   index by pls_integer;
  found  found_type ;
  result shortest_paths_3b := shortest_paths_3b();
  seq    pls_integer;
begin
  result.extend;
  result(1) := shortest_path_3b(start_actor, 0);
  found(start_actor) := null;
  seq := 1;
  
  while result.exists(seq) loop
    exit when result(seq).bacon# > 6;   -- "Six Degrees of Kevin Bacon"
    for neighbor in (
      select
         ca.actor_id_2
      from co_actors_top250 ca
      where ca.actor_id_1 = result(seq).actor_id
    ) loop
      if not found.exists(neighbor.actor_id_2) then
        result.extend;
        result(result.last) := shortest_path_3b(neighbor.actor_id_2, result(seq).bacon# + 1);
        found(neighbor.actor_id_2) := null;
      end if;
    end loop;
    pipe row (result(seq));
    result.delete(seq);
    seq := seq + 1;
  end loop;
end bacon3b_top250;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
from actors_top250 a1
cross apply bacon3b_top250(a1.id) bs
join actors_top250 a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)'
order by bs.bacon# desc, bs.actor_id;



/*
PL/SQL Breadth-First on full file
*/

create or replace function bacon3b_full(
   start_actor    actors_full.id%type
)
   return shortest_paths_3b pipelined
as
  type   found_type is table of boolean   index by pls_integer;
  found  found_type ;
  result shortest_paths_3b := shortest_paths_3b();
  seq    pls_integer;
begin
  result.extend;
  result(1) := shortest_path_3b(start_actor, 0);
  found(start_actor) := null;
  seq := 1;
  
  while result.exists(seq) loop
    exit when result(seq).bacon# > 6;   -- "Six Degrees of Kevin Bacon"
    for neighbor in (
      select
         ca.actor_id_2
      from co_actors_full ca
      where ca.actor_id_1 = result(seq).actor_id
    ) loop
      if not found.exists(neighbor.actor_id_2) then
        result.extend;
        result(result.last) := shortest_path_3b(neighbor.actor_id_2, result(seq).bacon# + 1);
        found(neighbor.actor_id_2) := null;
      end if;
    end loop;
    pipe row (result(seq));
    result.delete(seq);
    seq := seq + 1;
  end loop;
end bacon3b_full;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
from actors_full a1
cross apply bacon3b_full(a1.id) bs
join actors_full a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)'
order by bs.bacon# desc, bs.actor_id;

