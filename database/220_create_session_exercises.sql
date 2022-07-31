create or replace function create_session_exercises(performed_session_id_ uuid) returns table ("like" performed_exercise)
AS $$
insert into performed_exercise (exercise_id, performed_session_id, name, reps, rest, weight )
    select * from draft_session_exercises(performed_session_id_)
returning *;
$$
LANGUAGE SQL;