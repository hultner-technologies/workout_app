-- There's a bug in this view. This should only inlcude one value per session,
-- user and exercise.
-- This view isn't used by anything so not critical.
-- The draft exercises version seem to function correctly.
create or replace view next_exercise_progression
    with (security_invoker=on)
    as (
with performed_exercise_base as (
    select pe.*
         , base_exercise_id
         , app_user_id,
         (select min(r) from unnest(pe.reps) r) >= s.progression_limit * e.reps
             as successful
    from performed_exercise pe
             join exercise e on pe.exercise_id = e.exercise_id
             join performed_session p
                 on pe.performed_session_id = p.performed_session_id
             join session_schedule s
                 on e.session_schedule_id = s.session_schedule_id
)
select
    distinct  on (fe.exercise_id, ps.performed_session_id) fe.exercise_id,
    ps.performed_session_id,
    ps.app_user_id,
    fe.name                         as name,
    array_fill(fe.reps, array[fe.sets]) as reps,
    array_fill(fe.rest, array[fe.sets]) as rest,
    coalesce(max(pe.weight), 0)
        + (case when pe.successful then fe.step_increment else 0 end)
        as weight
from performed_session ps
         join full_exercise fe
             on ps.session_schedule_id = fe.session_schedule_id
         left join performed_exercise_base pe
                   on fe.base_exercise_id = pe.base_exercise_id
                          and pe.app_user_id = ps.app_user_id
group by fe.base_exercise_id
       , fe.name
       , fe.exercise_id
       , ps.performed_session_id
       , fe.reps
       , fe.sets
       , fe.rest
       , fe.step_increment
       , pe.successful
order by fe.exercise_id
);
