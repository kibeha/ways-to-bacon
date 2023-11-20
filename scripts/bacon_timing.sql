set serveroutput on;

declare
   runtime number;
   
   function do_exec (
      funcname    varchar2
    , tabsize     varchar2
    , run#        pls_integer
   )
      return number
   is
      startts     timestamp(6);
      endts       timestamp(6);
      seconds     number;
      type rec_t is record (
         actor_id       number
       , actor_name     varchar2(255)
       , bacon#         number
       , connect_path   varchar2(100)
      );
      type rec_tt is table of rec_t index by pls_integer;
      cur         sys_refcursor;
      recs        rec_tt;
      cnt         pls_integer := 0;
      procedure out (text varchar2) is
      begin
         dbms_output.put_line(funcname||' '||tabsize||' '||run#||': '||text);
      end;
   begin
      startts := systimestamp;
      out(to_char(startts,'HH24:MI:SS.FF6')||' begin');
      
      -- ---------------------------------------------
      if funcname in ('bacon1','bacon2','bacon3') then
         open cur for
q'[select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , bs.connect_path
from actors_]'||tabsize||q'[ a1
cross apply ]'||funcname||q'[_]'||tabsize||q'[(a1.id) bs
join actors_]'||tabsize||q'[ a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)']'
         ;
      -- ---------------------------------------------
      elsif funcname = 'bacon3b' then
         open cur for
q'[select
   bs.actor_id
 , a2.actor
 , bs.bacon#
 , null as connect_path
from actors_]'||tabsize||q'[ a1
cross apply ]'||funcname||q'[_]'||tabsize||q'[(a1.id) bs
join actors_]'||tabsize||q'[ a2
   on a2.id = bs.actor_id
where a1.actor = 'Kevin Bacon (I)']'
         ;
      -- ---------------------------------------------
      elsif funcname = 'sql' then
         open cur for
q'[with recursor (
   actor_id, bacon#, connect_path, all_found, rn
) as (
   select
      actor.id
    , 0
    , to_clob(actor.id)
    , id_list(actor.id)
    , 1
   from actors_]'||tabsize||q'[ actor
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
   join co_actors_]'||tabsize||q'[ ca
      on ca.actor_id_1 = r.actor_id
      and not ca.actor_id_2 member of r.all_found
   where r.rn = 1
   and   r.bacon# < 6
)
   cycle actor_id set is_cycle to 'Y' default 'N'
select
   r.actor_id
 , a.actor
 , r.bacon#
 , r.connect_path
from recursor r
join actors_]'||tabsize||q'[ a
   on a.id = r.actor_id
where r.rn = 1
order by r.bacon# desc, r.actor_id]'
         ;
      -- ---------------------------------------------
      else
         return -1;
      end if;      
      
      loop
         fetch cur bulk collect into recs limit 1000;
         exit when recs.count = 0;
         cnt := cnt + recs.count;
      end loop;

      endts := systimestamp;
      out(to_char(endts,'HH24:MI:SS.FF6')||' end');

      seconds := extract(second from endts-startts)
               + 60 * extract(minute from endts-startts)
               + 60 * 60 * extract(hour from endts-startts);
      out('seconds: '||seconds||' - rows: '||cnt);

      return seconds;
   end;
   function exec (
      funcname    varchar2
    , tabsize     varchar2
    , no_runs     pls_integer default 3
   )
      return number
   is
      runtime     number;
      runtime_tot number := 0;
      runtime_avg number;
   begin
      for run# in 1..no_runs loop
         runtime := do_exec(funcname, tabsize, run#);
         runtime_tot := runtime_tot + runtime;
      end loop;
      runtime_avg := runtime_tot / no_runs;
      dbms_output.put_line('----------------------------------------------------');
      dbms_output.put_line(funcname||' '||tabsize||' average: '||runtime_avg);
      dbms_output.put_line('----------------------------------------------------');
      return runtime_avg;
   end;
begin
   /* */
   runtime := exec('sql','small');
   runtime := exec('bacon1','small');
   runtime := exec('bacon2','small');
   runtime := exec('bacon3','small');
   runtime := exec('bacon3b','small');
   /* */
   --runtime := exec('sql','top250');  -- Not sufficient TEMP
   runtime := exec('bacon1','top250');
   runtime := exec('bacon2','top250');
   runtime := exec('bacon3','top250');
   runtime := exec('bacon3b','top250');
   /* */
   --runtime := exec('sql','full');    -- Don't even try
   --runtime := exec('bacon1','full'); -- Not sufficient PGA
   --runtime := exec('bacon2','full'); -- Not sufficient PGA
   runtime := exec('bacon3','full');
   runtime := exec('bacon3b','full');
   /* */
end;
/

