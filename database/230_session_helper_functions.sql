-- Functions to make it easier to setup new sessions.
-- Mainly for use when interacting the database directly.

-- Defaults to me for now
CREATE OR REPLACE FUNCTION create_session_from_name(schedule_name text, app_user_id uuid default '65585c04-0525-11ed-9a8f-0bd67a64ac86'::uuid)
 RETURNS TABLE("like" performed_session)
 LANGUAGE sql
AS $function$
insert into performed_session ( session_schedule_id, app_user_id )
values (
    ( select ss.session_schedule_id from session_schedule ss where ss.name=schedule_name )
    , app_user_id
)
returning *;
$function$;

-- Defaults to me for now
CREATE OR REPLACE FUNCTION create_full_session(schedule_name text, app_user_id uuid default '65585c04-0525-11ed-9a8f-0bd67a64ac86'::uuid)
 RETURNS TABLE("like" performed_exercise)
 LANGUAGE sql
AS $function$
select * from create_session_exercises(
	(select performed_session_id from create_session_from_name(schedule_name, app_user_id))
);
$function$;
