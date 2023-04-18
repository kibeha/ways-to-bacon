/*
Loading data from these 3 files into tables.

https://cs.oberlin.edu/~gr151/imdb/imdb.small.txt
https://cs.oberlin.edu/~gr151/imdb/imdb.top250.txt
https://cs.oberlin.edu/~gr151/imdb/imdb.full.txt

This assumes user has privileges to use APEX_WEB_SERVICE package and rights via ACL to call those URLs.
*/


/*
Create helper objects to parse the files
*/

create or replace type t_imdb as object (
   actor varchar2(255)
 , movie varchar2(255)
);
/

create or replace type t_imdb_row as table of t_imdb;
/

create or replace function t_imdb_parser (
   p_clob in clob
)
   return t_imdb_row pipelined
is
   l_buffer    varchar2(512);
   l_cr        varchar2(1) := chr(10);
   l_delim     varchar2(1) := '|';
   l_crpos1    pls_integer := 0;
   l_crpos2    pls_integer;
   l_delimpos  pls_integer;
begin
   loop
      l_crpos2 := dbms_lob.instr(p_clob, l_cr, l_crpos1+1);
      l_buffer := dbms_lob.substr(p_clob, l_crpos2-l_crpos1-1, l_crpos1+1);
      exit when l_buffer is null;

      l_delimpos := instr(l_buffer, '|');
      pipe row(t_imdb(substr(l_buffer,1,l_delimpos-1),substr(l_buffer,l_delimpos+1)));
 
      l_crpos1 := l_crpos2;
   end loop;
 
   return;
exception
   when no_data_needed then
      null;
end t_imdb_parser;
/


/*
Create and load small file
*/

create table raw_imdb_small (
   actor varchar2(255)
 , movie varchar2(255)
);

insert into raw_imdb_small
select *
from t_imdb_parser(
   apex_web_service.make_rest_request('https://cs.oberlin.edu/~gr151/imdb/imdb.small.txt', 'GET')
);

commit;

select
   count(*)
 , count(distinct actor)
 , count(distinct movie)
 , count(distinct actor || '|' || movie)
from raw_imdb_small;

select * from raw_imdb_small;

/*
Create and load top250 file
*/

create table raw_imdb_top250 (
   actor varchar2(255)
 , movie varchar2(255)
);

insert into raw_imdb_top250
select *
from t_imdb_parser(
   apex_web_service.make_rest_request('https://cs.oberlin.edu/~gr151/imdb/imdb.top250.txt', 'GET')
);

commit;

select
   count(*)
 , count(distinct actor)
 , count(distinct movie)
 , count(distinct actor || '|' || movie)
from raw_imdb_top250;

/*
Create and load full file
*/

create table raw_imdb_full (
   actor varchar2(255)
 , movie varchar2(255)
);

insert into raw_imdb_full
select *
from t_imdb_parser(
   apex_web_service.make_rest_request('https://cs.oberlin.edu/~gr151/imdb/imdb.full.txt', 'GET')
);

commit;

select
   count(*)
 , count(distinct actor)
 , count(distinct movie)
 , count(distinct actor || '|' || movie)
from raw_imdb_full
;

