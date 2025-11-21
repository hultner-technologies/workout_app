
CREATE TABLE performed_session (
    performed_session_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , session_schedule_id uuid REFERENCES session_schedule(session_schedule_id) NOT NULL
    , app_user_id uuid REFERENCES app_user(app_user_id) NOT NULL
    , started_at timestamp default now()
    , completed_at timestamp default now()
    , note text
    , data jsonb
);
