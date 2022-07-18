


begin;
insert into performed_exercise (exercise_id, performed_session_id, name, reps, rest, weight )
with performed_exercise_base as (
    select pe.*, base_exercise_id, app_user_id,
       (select min(r) from unnest(pe.reps) r) >= s.progression_limit * e.reps as successful
    from performed_exercise pe
      join exercise e on pe.exercise_id = e.exercise_id
      join performed_session p on pe.performed_session_id = p.performed_session_id
      join session_schedule s on e.session_schedule_id = s.session_schedule_id
    --where min_rep > s.progression_limit * pe.reps
)
select -- fe.base_exercise_id,
       distinct  on (fe.exercise_id) fe.exercise_id,
       ps.performed_session_id,
       fe.name                         as name,
       array_fill(fe.reps, array[fe.sets]) as reps,
       array_fill(fe.rest, array[fe.sets]) as rest,
       coalesce(max(pe.weight), 0) + (case when pe.successful then 1000 else 0 end) as weight
       --,ps.*
from performed_session ps
         join full_exercise fe on ps.session_schedule_id = fe.session_schedule_id
--left join performed_session ps on ss.session_schedule_id = ps.session_schedule_id
         left join performed_exercise_base pe
                   on fe.base_exercise_id = pe.base_exercise_id and pe.app_user_id = ps.app_user_id --and pe.successful is true
--        join session_schedule ss on ps.session_schedule_id = ss.session_schedule_id
where ps.performed_session_id = 'b471eaca-06b6-11ed-90f0-27ca8b4a97dd'
-- where ps.performed_session_id = 'a81bf8b6-0552-11ed-8ca8-2f43c70ed34a'
--where ps.performed_session_id = '8c7dc2da-06db-11ed-b188-3b4f8ed28e05'
--and (sort(cast(pe.reps as INT[]))[1] > 8
group by fe.base_exercise_id, fe.name, fe.exercise_id, ps.performed_session_id, fe.reps, fe.sets, fe.rest, pe.successful --ps.performed_session_id, ps.session_schedule_id, ps.app_user_id, ps.started_at, ps.completed_at, ps.note, ps.data
order by fe.exercise_id;
--having min(pe.reps) > min(ss.progression_limit)*max(fe.reps)
select * from performed_exercise
 --where performed_session_id = 'a81bf8b6-0552-11ed-8ca8-2f43c70ed34a';
order by started_at desc;
rollback;
end;