/*
Assume normalized tables have been created and loaded

Adapted from Mathguy BFS (Breadth First Search) PL/SQL solution on forums:

https://community.oracle.com/tech/developers/discussion/comment/16797341/#Comment_16797341
*/

/*
Types for table function
*/

create or replace type shortest_path as object (
   actor_id       number
 , bacon#         number
 , connect_path   varchar2(100)
)
/
create or replace type shortest_paths as table of shortest_path
/


/*
PL/SQL Breadth-First on small file
*/

create or replace function bacon1_small(
   start_actor    actors_small.id%type
)
   return shortest_paths
as
  cursor edge_cur
  is
      select
         ca.actor_id_1
       , ca.actor_id_2
      from co_actors_small ca;

  type edges_type     is table of edge_cur%rowtype;
  type neighbors_type is table of boolean        index by pls_integer;
  type adj_list_type  is table of neighbors_type index by pls_integer;
  edges     edges_type;
  adjacent  adj_list_type;
  result    shortest_paths := shortest_paths();
  seq       pls_integer;
  j         pls_integer;

  procedure cleanup(vertice pls_integer) is
    k pls_integer;
  begin
    k := adjacent.first;
    while k is not null loop
      if adjacent(k).exists(vertice) then
        adjacent(k).delete(vertice);
      end if;
      k := adjacent.next(k);
    end loop;
  end cleanup;

begin
  open edge_cur;
  fetch edge_cur bulk collect into edges;
  close edge_cur;
  for i in 1..edges.last loop
    adjacent(edges(i).actor_id_1)(edges(i).actor_id_2) := null;
  end loop;
 
  result.extend;
  result(1) := shortest_path(start_actor, 0, start_actor);
  cleanup(start_actor);
  seq := 1;
  
  while result.exists(seq) loop
     exit when result(seq).bacon# >= 6;   -- "Six Degrees of Kevin Bacon"
     j := adjacent(result(seq).actor_id).first;
     while j is not null loop
       result.extend;
       result(result.last) := shortest_path(j, result(seq).bacon# + 1, result(seq).connect_path || '->' || j);
       cleanup(j);
       j := adjacent(result(seq).actor_id).next(j);
     end loop;
    adjacent.delete(result(seq).actor_id);
    seq := seq + 1;
  end loop;
  return result;
end bacon1_small;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_small a1
cross apply bacon1_small(a1.id) bs
join actors_small a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)'
order by bs.bacon# desc, bs.actor_id;


/*
PL/SQL Breadth-First on top250 file
*/

create or replace function bacon1_top250(
   start_actor    actors_top250.id%type
)
   return shortest_paths
as
  cursor edge_cur
  is
      select
         ca.actor_id_1
       , ca.actor_id_2
      from co_actors_top250 ca;

  type edges_type     is table of edge_cur%rowtype;
  type neighbors_type is table of boolean        index by pls_integer;
  type adj_list_type  is table of neighbors_type index by pls_integer;
  edges     edges_type;
  adjacent  adj_list_type;
  result    shortest_paths := shortest_paths();
  seq       pls_integer;
  j         pls_integer;

  procedure cleanup(vertice pls_integer) is
    k pls_integer;
  begin
    k := adjacent.first;
    while k is not null loop
      if adjacent(k).exists(vertice) then
        adjacent(k).delete(vertice);
      end if;
      k := adjacent.next(k);
    end loop;
  end cleanup;

begin
  open edge_cur;
  fetch edge_cur bulk collect into edges;
  close edge_cur;
  for i in 1..edges.last loop
    adjacent(edges(i).actor_id_1)(edges(i).actor_id_2) := null;
  end loop;
 
  result.extend;
  result(1) := shortest_path(start_actor, 0, start_actor);
  cleanup(start_actor);
  seq := 1;
  
  while result.exists(seq) loop
     exit when result(seq).bacon# >= 6;   -- "Six Degrees of Kevin Bacon"
     j := adjacent(result(seq).actor_id).first;
     while j is not null loop
       result.extend;
       result(result.last) := shortest_path(j, result(seq).bacon# + 1, result(seq).connect_path || '->' || j);
       cleanup(j);
       j := adjacent(result(seq).actor_id).next(j);
     end loop;
    adjacent.delete(result(seq).actor_id);
    seq := seq + 1;
  end loop;
  return result;
end bacon1_top250;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_top250 a1
cross apply bacon1_top250(a1.id) bs
join actors_top250 a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)'
order by bs.bacon# desc, bs.actor_id;



/*
PL/SQL Breadth-First on full file

ORA-04036: PGA memory used by the instance exceeds PGA_AGGREGATE_LIMIT
*/

create or replace function bacon1_full(
   start_actor    actors_full.id%type
)
   return shortest_paths
as
   cursor edge_cur
   is
      select
         ca.actor_id_1
       , ca.actor_id_2
      from co_actors_full ca;
  type edges_type     is table of edge_cur%rowtype;
  type neighbors_type is table of boolean        index by pls_integer;
  type adj_list_type  is table of neighbors_type index by pls_integer;
  edges     edges_type;
  adjacent  adj_list_type;
  result    shortest_paths := shortest_paths();
  seq       pls_integer;
  j         pls_integer;

  procedure cleanup(vertice pls_integer) is
    k pls_integer;
  begin
    k := adjacent.first;
    while k is not null loop
      if adjacent(k).exists(vertice) then
        adjacent(k).delete(vertice);
      end if;
      k := adjacent.next(k);
    end loop;
  end cleanup;

begin
  open edge_cur;
  fetch edge_cur bulk collect into edges;
  close edge_cur;
  for i in 1..edges.last loop
    adjacent(edges(i).actor_id_1)(edges(i).actor_id_2) := null;
  end loop;
 
  result.extend;
  result(1) := shortest_path(start_actor, 0, start_actor);
  cleanup(start_actor);
  seq := 1;
  
  while result.exists(seq) loop
     exit when result(seq).bacon# >= 6;   -- "Six Degrees of Kevin Bacon"
     j := adjacent(result(seq).actor_id).first;
     while j is not null loop
       result.extend;
       result(result.last) := shortest_path(j, result(seq).bacon# + 1, result(seq).connect_path || '->' || j);
       cleanup(j);
       j := adjacent(result(seq).actor_id).next(j);
     end loop;
    adjacent.delete(result(seq).actor_id);
    seq := seq + 1;
  end loop;
  return result;
end bacon1_full;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_full a1
cross apply bacon1_full(a1.id) bs
join actors_full a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)'
order by bs.bacon# desc, bs.actor_id;

