/*
Assume normalized tables have been created and loaded

Version of modified BFS PL/SQL solution by kibeha that takes both start and end actor parameter
*/


/*
Problem with previous implementations:
Query like this will calculate bacon#/path for ALL actors,
and THEN filter on Al Pacino
*/


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
and a2.actor = 'Al Pacino';


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

create or replace function bacon4_small(
   start_actor    actors_small.id%type
 , end_actor      actors_small.id%type
)
   return shortest_paths
as
  type      found_type is table of pls_integer index by pls_integer;
  found1    found_type ;
  result1   shortest_paths := shortest_paths();
  seq1      pls_integer;
  found2    found_type ;
  result2   shortest_paths := shortest_paths();
  seq2      pls_integer;
  retval    shortest_path;
  
  function reverse_path (path_in varchar2)
    return varchar2
  is
    reversed varchar2(4000);
    pos1     pls_integer;
    pos2     pls_integer;
  begin
    pos1 := 1;
    loop
       pos2 := instr(path_in || '->', '->', pos1);
       exit when pos2 = 0 or pos2 is null;
--       reversed := substr(path_in, pos1, pos2 - pos1) || nvl2(reversed, '->', '') || reversed; -- NVL2 works in PL/SQL in 21c - in 19c need to use CASE
       reversed := substr(path_in, pos1, pos2 - pos1) || case when reversed is not null then '->' end || reversed;
       pos1 := pos2 + 2;
    end loop;
    return reversed;
  end;
begin
  result1.extend;
  result1(1) := shortest_path(start_actor, 0, start_actor);
  found1(start_actor) := 1;
  seq1 := 1;

  result2.extend;
  result2(1) := shortest_path(end_actor, 0, end_actor);
  found2(end_actor) := 1;
  seq2 := 1;
  
  <<bacon_loop>>
  for baconloop in 1..3 loop

     while result1.exists(seq1) loop
       exit when result1(seq1).bacon# >= baconloop;
       for neighbor in (
         select
            ca.actor_id_2
         from co_actors_small ca
         where ca.actor_id_1 = result1(seq1).actor_id
       ) loop
         if found2.exists(neighbor.actor_id_2) then
            retval := shortest_path(
                         end_actor
                       , result1(seq1).bacon# + result2(found2(neighbor.actor_id_2)).bacon# + 1
                       , result1(seq1).connect_path || '->' || reverse_path(result2(found2(neighbor.actor_id_2)).connect_path)
                      );
            exit bacon_loop;
         end if;
         if not found1.exists(neighbor.actor_id_2) then
           result1.extend;
           result1(result1.last) := shortest_path(neighbor.actor_id_2, result1(seq1).bacon# + 1, result1(seq1).connect_path || '->' || neighbor.actor_id_2);
           found1(neighbor.actor_id_2) := result1.last;
         end if;
       end loop;
       seq1 := seq1 + 1;
     end loop;

     while result2.exists(seq2) loop
       exit when result1(seq2).bacon# >= baconloop;
       for neighbor in (
         select
            ca.actor_id_2
         from co_actors_small ca
         where ca.actor_id_1 = result2(seq2).actor_id
       ) loop
         if found1.exists(neighbor.actor_id_2) then
            retval := shortest_path(
                         end_actor
                       , result1(found1(neighbor.actor_id_2)).bacon# + result2(seq2).bacon# + 1
                       , result1(found1(neighbor.actor_id_2)).connect_path || '->' || reverse_path(result2(seq2).connect_path)
                      );
            exit bacon_loop;
         end if;
         if not found2.exists(neighbor.actor_id_2) then
           result2.extend;
           result2(result2.last) := shortest_path(neighbor.actor_id_2, result2(seq2).bacon# + 1, result2(seq2).connect_path || '->' || neighbor.actor_id_2);
           found2(neighbor.actor_id_2) := result2.last;
         end if;
       end loop;
       seq2 := seq2 + 1;
     end loop;

  end loop;
  
  return shortest_paths(retval);
end bacon4_small;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_small a1
cross join actors_small a2
cross apply bacon4_small(a1.id, a2.id) bs
where a1.actor = 'Kevin Bacon (I)'
and a2.actor = 'Al Pacino';



/*
PL/SQL Breadth-First on top250 file
*/

create or replace function bacon4_top250(
   start_actor    actors_top250.id%type
 , end_actor      actors_top250.id%type
)
   return shortest_paths
as
  type      found_type is table of pls_integer index by pls_integer;
  found1    found_type ;
  result1   shortest_paths := shortest_paths();
  seq1      pls_integer;
  found2    found_type ;
  result2   shortest_paths := shortest_paths();
  seq2      pls_integer;
  retval    shortest_path;
  
  function reverse_path (path_in varchar2)
    return varchar2
  is
    reversed varchar2(4000);
    pos1     pls_integer;
    pos2     pls_integer;
  begin
    pos1 := 1;
    loop
       pos2 := instr(path_in || '->', '->', pos1);
       exit when pos2 = 0 or pos2 is null;
--       reversed := substr(path_in, pos1, pos2 - pos1) || nvl2(reversed, '->', '') || reversed; -- NVL2 works in PL/SQL in 21c - in 19c need to use CASE
       reversed := substr(path_in, pos1, pos2 - pos1) || case when reversed is not null then '->' end || reversed;
       pos1 := pos2 + 2;
    end loop;
    return reversed;
  end;
begin
  result1.extend;
  result1(1) := shortest_path(start_actor, 0, start_actor);
  found1(start_actor) := 1;
  seq1 := 1;

  result2.extend;
  result2(1) := shortest_path(end_actor, 0, end_actor);
  found2(end_actor) := 1;
  seq2 := 1;
  
  <<bacon_loop>>
  for baconloop in 1..3 loop

     while result1.exists(seq1) loop
       exit when result1(seq1).bacon# >= baconloop;
       for neighbor in (
         select
            ca.actor_id_2
         from co_actors_top250 ca
         where ca.actor_id_1 = result1(seq1).actor_id
       ) loop
         if found2.exists(neighbor.actor_id_2) then
            retval := shortest_path(
                         end_actor
                       , result1(seq1).bacon# + result2(found2(neighbor.actor_id_2)).bacon# + 1
                       , result1(seq1).connect_path || '->' || reverse_path(result2(found2(neighbor.actor_id_2)).connect_path)
                      );
            exit bacon_loop;
         end if;
         if not found1.exists(neighbor.actor_id_2) then
           result1.extend;
           result1(result1.last) := shortest_path(neighbor.actor_id_2, result1(seq1).bacon# + 1, result1(seq1).connect_path || '->' || neighbor.actor_id_2);
           found1(neighbor.actor_id_2) := result1.last;
         end if;
       end loop;
       seq1 := seq1 + 1;
     end loop;

     while result2.exists(seq2) loop
       exit when result1(seq2).bacon# >= baconloop;
       for neighbor in (
         select
            ca.actor_id_2
         from co_actors_top250 ca
         where ca.actor_id_1 = result2(seq2).actor_id
       ) loop
         if found1.exists(neighbor.actor_id_2) then
            retval := shortest_path(
                         end_actor
                       , result1(found1(neighbor.actor_id_2)).bacon# + result2(seq2).bacon# + 1
                       , result1(found1(neighbor.actor_id_2)).connect_path || '->' || reverse_path(result2(seq2).connect_path)
                      );
            exit bacon_loop;
         end if;
         if not found2.exists(neighbor.actor_id_2) then
           result2.extend;
           result2(result2.last) := shortest_path(neighbor.actor_id_2, result2(seq2).bacon# + 1, result2(seq2).connect_path || '->' || neighbor.actor_id_2);
           found2(neighbor.actor_id_2) := result2.last;
         end if;
       end loop;
       seq2 := seq2 + 1;
     end loop;

  end loop;
  
  return shortest_paths(retval);
end bacon4_top250;
/

select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_top250 a1
cross join actors_top250 a2
cross apply bacon4_top250(a1.id, a2.id) bs
where a1.actor = 'Kevin Bacon (I)'
and a2.actor = 'Michael J. Fox (I)';


select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_top250 a1
cross join actors_top250 a2
cross apply bacon4_top250(a1.id, a2.id) bs
where a1.actor = 'Kevin Bacon (I)'
and a2.actor = 'Elzbieta Jasinska';



/*
PL/SQL Breadth-First on full file
*/

create or replace function bacon4_full(
   start_actor    actors_full.id%type
 , end_actor      actors_full.id%type
)
   return shortest_paths
as
  type      found_type is table of pls_integer index by pls_integer;
  found1    found_type ;
  result1   shortest_paths := shortest_paths();
  seq1      pls_integer;
  found2    found_type ;
  result2   shortest_paths := shortest_paths();
  seq2      pls_integer;
  retval    shortest_path;
  
  function reverse_path (path_in varchar2)
    return varchar2
  is
    reversed varchar2(4000);
    pos1     pls_integer;
    pos2     pls_integer;
  begin
    pos1 := 1;
    loop
       pos2 := instr(path_in || '->', '->', pos1);
       exit when pos2 = 0 or pos2 is null;
--       reversed := substr(path_in, pos1, pos2 - pos1) || nvl2(reversed, '->', '') || reversed; -- NVL2 works in PL/SQL in 21c - in 19c need to use CASE
       reversed := substr(path_in, pos1, pos2 - pos1) || case when reversed is not null then '->' end || reversed;
       pos1 := pos2 + 2;
    end loop;
    return reversed;
  end;
begin
  result1.extend;
  result1(1) := shortest_path(start_actor, 0, start_actor);
  found1(start_actor) := 1;
  seq1 := 1;

  result2.extend;
  result2(1) := shortest_path(end_actor, 0, end_actor);
  found2(end_actor) := 1;
  seq2 := 1;
  
  <<bacon_loop>>
  for baconloop in 1..3 loop

     while result1.exists(seq1) loop
       exit when result1(seq1).bacon# >= baconloop;
       for neighbor in (
         select
            ca.actor_id_2
         from co_actors_full ca
         where ca.actor_id_1 = result1(seq1).actor_id
       ) loop
         if found2.exists(neighbor.actor_id_2) then
            retval := shortest_path(
                         end_actor
                       , result1(seq1).bacon# + result2(found2(neighbor.actor_id_2)).bacon# + 1
                       , result1(seq1).connect_path || '->' || reverse_path(result2(found2(neighbor.actor_id_2)).connect_path)
                      );
            exit bacon_loop;
         end if;
         if not found1.exists(neighbor.actor_id_2) then
           result1.extend;
           result1(result1.last) := shortest_path(neighbor.actor_id_2, result1(seq1).bacon# + 1, result1(seq1).connect_path || '->' || neighbor.actor_id_2);
           found1(neighbor.actor_id_2) := result1.last;
         end if;
       end loop;
       seq1 := seq1 + 1;
     end loop;

     while result2.exists(seq2) loop
       exit when result1(seq2).bacon# >= baconloop;
       for neighbor in (
         select
            ca.actor_id_2
         from co_actors_full ca
         where ca.actor_id_1 = result2(seq2).actor_id
       ) loop
         if found1.exists(neighbor.actor_id_2) then
            retval := shortest_path(
                         end_actor
                       , result1(found1(neighbor.actor_id_2)).bacon# + result2(seq2).bacon# + 1
                       , result1(found1(neighbor.actor_id_2)).connect_path || '->' || reverse_path(result2(seq2).connect_path)
                      );
            exit bacon_loop;
         end if;
         if not found2.exists(neighbor.actor_id_2) then
           result2.extend;
           result2(result2.last) := shortest_path(neighbor.actor_id_2, result2(seq2).bacon# + 1, result2(seq2).connect_path || '->' || neighbor.actor_id_2);
           found2(neighbor.actor_id_2) := result2.last;
         end if;
       end loop;
       seq2 := seq2 + 1;
     end loop;

  end loop;
  
  return shortest_paths(retval);
end bacon4_full;
/

-- Bacon# 2:
select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_full a1
cross join actors_full a2
cross apply bacon4_full(a1.id, a2.id) bs
where a1.actor = 'Kevin Bacon (I)'
and a2.actor = 'Michael J. Fox (I)';


-- Bacon# 3:
select a1.*,
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_full a1
cross join actors_full a2
cross apply bacon4_full(a1.id, a2.id) bs
where a1.actor = 'Kevin Bacon (I)'
and a2.actor = 'Brigitte Helm';


-- Also Bacon# 3 - but takes longer:
select a1.*,
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_full a1
cross join actors_full a2
cross apply bacon4_full(a1.id, a2.id) bs
where a1.actor = 'Kevin Bacon (I)'
and a2.actor = 'Eliane Tayar';


-- Bacon# 6:
select a1.*,
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_full a1
cross join actors_full a2
cross apply bacon4_full(a1.id, a2.id) bs
where a1.actor = 'Kevin Bacon (I)'
and a2.actor = 'Muhibbat Abdusalam';


