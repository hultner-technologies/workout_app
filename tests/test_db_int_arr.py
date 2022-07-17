from sqlalchemy import ARRAY
from sqlalchemy import Column
from sqlalchemy import create_engine
from sqlalchemy import Integer
from sqlalchemy import text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import Session
import psycopg2

Base = declarative_base()


class PerformedExercise(Base):
    __tablename__ = "performed_exercise"

    performed_exercise_id = Column(UUID, server_default=text("uuid_generate_v1mc()"), primary_key=True)
    reps = Column(ARRAY(Integer), nullable=False)



e = create_engine("postgresql://hultner@localhost/test", echo="debug")
# Base.metadata.drop_all(e)
# Base.metadata.create_all(e)

# Set up db
setup_query = """
-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Custom data types and domains
DO $$
    BEGIN
        IF NOT EXISTS(SELECT 1 from pg_type WHERE typname = 'positive_int') THEN
            CREATE DOMAIN positive_int AS int
                CHECK(VALUE >= 0);
        END IF;
    END
$$;

DROP TABLE IF EXISTS performed_exercise;
CREATE TABLE performed_exercise (
    performed_exercise_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , reps positive_int[] NOT NULL
);
"""
with Session(e) as sess:
    sess.execute(setup_query)
    sess.commit()
    oids = sess.execute("select typarray from pg_type where typname = 'positive_int'")

psycopg2.extensions.register_type(
    psycopg2.extensions.new_array_type(tuple(*oids), 'positive_int[]', psycopg2.extensions.INTEGER)
)

data = [10, 1, 10, 1]
with Session(e) as sess:
    pe = PerformedExercise(reps=data)
    sess.add(pe)
    sess.commit()
    pe_id = pe.performed_exercise_id

with Session(e) as sess:
    pe = sess.get(PerformedExercise, pe_id)
    assert pe.reps == data
    print(pe.reps)
