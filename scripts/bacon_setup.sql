/*
Assume these files have been copied to a storage bucket on Oracle Cloud

http://cs.oberlin.edu/~gr151/imdb/imdb.small.txt
http://cs.oberlin.edu/~gr151/imdb/imdb.top250.txt
http://cs.oberlin.edu/~gr151/imdb/imdb.full.txt

URIs to the files in the storage bucket is on the form:

'https://objectstorage.<datacenter>.oraclecloud.com/n/<id>/b/<bucket name>/o/<file name>'

Alternatively load the files to tables raw_imdb_* in any other way desired.
*/


/*
Create a credential to access the storage bucket
*/

begin
dbms_cloud.create_credential(
   'EXAMPLE_CREDENT'
 , 'oracleidentitycloudservice/myuser@example.com'
 , '<generated Auth Token>'
);
end;
/


/*
Create and load small file
*/

create table raw_imdb_small (
   actor varchar2(255)
 , movie varchar2(255)
);

begin  
   dbms_cloud.copy_data(   
      table_name        => 'RAW_IMDB_SMALL'
    , credential_name   => 'EXAMPLE_CREDENT'
    , file_uri_list     => '<URI to storage bucket>/o/imdb.small.txt'
    , format            => json_object('delimiter' value '|')
   );
end;
/ 

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

begin  
   dbms_cloud.copy_data(   
      table_name        => 'RAW_IMDB_TOP250'
    , credential_name   => 'EXAMPLE_CREDENT'
    , file_uri_list     => '<URI to storage bucket>/o/imdb.top250.txt'
    , format            => json_object('delimiter' value '|')
   );
end;
/ 

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

begin  
   dbms_cloud.copy_data(   
      table_name        => 'RAW_IMDB_TOP250'
    , credential_name   => 'EXAMPLE_CREDENT'
    , file_uri_list     => '<URI to storage bucket>/o/imdb.full.txt'
    , format            => json_object('delimiter' value '|')
   );
end;
/ 

select
   count(*)
 , count(distinct actor)
 , count(distinct movie)
 , count(distinct actor || '|' || movie)
from raw_imdb_full;

