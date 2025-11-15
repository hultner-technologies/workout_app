# mypy: ignore-errors
from sqlalchemy import (
    ARRAY,
    CheckConstraint,
    Column,
    Computed,
    DateTime,
    ForeignKeyConstraint,
    Integer,
    Numeric,
    PrimaryKeyConstraint,
    Text,
    text,
)
from sqlalchemy.dialects.postgresql import INTERVAL, JSONB, UUID
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


class AppUser(Base):
    __tablename__ = "app_user"
    __table_args__ = (PrimaryKeyConstraint("app_user_id", name="app_user_pkey"),)

    app_user_id = Column(UUID, server_default=text("uuid_generate_v1mc()"))
    name = Column(Text, nullable=False)
    email = Column(Text, nullable=False)
    password = Column(Text)
    data = Column(JSONB)

    performed_session = relationship("PerformedSession", back_populates="app_user")


class BaseExercise(Base):
    __tablename__ = "base_exercise"
    __table_args__ = (PrimaryKeyConstraint("base_exercise_id", name="base_exercise_pkey"),)

    base_exercise_id = Column(UUID, server_default=text("uuid_generate_v1mc()"))
    name = Column(Text, nullable=False)
    description = Column(Text)
    links = Column(ARRAY(Text()))
    data = Column(JSONB)

    exercise = relationship("Exercise", back_populates="base_exercise")


class Plan(Base):
    __tablename__ = "plan"
    __table_args__ = (PrimaryKeyConstraint("plan_id", name="plan_pkey"),)

    plan_id = Column(UUID, server_default=text("uuid_generate_v1mc()"))
    name = Column(Text, nullable=False)
    description = Column(Text)
    links = Column(ARRAY(Text()))
    data = Column(JSONB)

    session_schedule = relationship("SessionSchedule", back_populates="plan")


class SessionSchedule(Base):
    __tablename__ = "session_schedule"
    __table_args__ = (
        CheckConstraint(
            "(progression_limit > (0)::numeric) AND (progression_limit < (1)::numeric)",
            name="session_schedule_progression_limit_check",
        ),
        ForeignKeyConstraint(["plan_id"], ["plan.plan_id"], name="session_schedule_plan_id_fkey"),
        PrimaryKeyConstraint("session_schedule_id", name="session_schedule_pkey"),
    )

    session_schedule_id = Column(UUID, server_default=text("uuid_generate_v1mc()"))
    plan_id = Column(UUID, nullable=False)
    name = Column(Text, nullable=False)
    progression_limit = Column(Numeric(2, 1), nullable=False)
    description = Column(Text)
    links = Column(ARRAY(Text()))
    data = Column(JSONB)

    plan = relationship("Plan", back_populates="session_schedule")
    exercise = relationship("Exercise", back_populates="session_schedule")
    performed_session = relationship("PerformedSession", back_populates="session_schedule")


class Exercise(Base):
    __tablename__ = "exercise"
    __table_args__ = (
        ForeignKeyConstraint(
            ["base_exercise_id"],
            ["base_exercise.base_exercise_id"],
            name="exercise_base_exercise_id_fkey",
        ),
        ForeignKeyConstraint(
            ["session_schedule_id"],
            ["session_schedule.session_schedule_id"],
            name="exercise_session_schedule_id_fkey",
        ),
        PrimaryKeyConstraint("exercise_id", name="exercise_pkey"),
    )

    exercise_id = Column(UUID, server_default=text("uuid_generate_v1mc()"))
    base_exercise_id = Column(UUID, nullable=False)
    session_schedule_id = Column(UUID, nullable=False)
    reps = Column(Integer, nullable=False, server_default=text("10"))
    sets = Column(Integer, nullable=False, server_default=text("5"))
    rest = Column(INTERVAL, nullable=False, server_default=text("'00:01:00'::interval"))
    data = Column(JSONB)

    base_exercise = relationship("BaseExercise", back_populates="exercise")
    session_schedule = relationship("SessionSchedule", back_populates="exercise")
    performed_exercise = relationship("PerformedExercise", back_populates="exercise")


class PerformedSession(Base):
    __tablename__ = "performed_session"
    __table_args__ = (
        ForeignKeyConstraint(
            ["app_user_id"],
            ["app_user.app_user_id"],
            name="performed_session_app_user_id_fkey",
        ),
        ForeignKeyConstraint(
            ["session_schedule_id"],
            ["session_schedule.session_schedule_id"],
            name="performed_session_session_schedule_id_fkey",
        ),
        PrimaryKeyConstraint("performed_session_id", name="performed_session_pkey"),
    )

    performed_session_id = Column(UUID, server_default=text("uuid_generate_v1mc()"))
    session_schedule_id = Column(UUID, nullable=False)
    app_user_id = Column(UUID, nullable=False)
    started_at = Column(DateTime, server_default=text("now()"))
    completed_at = Column(DateTime, server_default=text("now()"))
    note = Column(Text)
    data = Column(JSONB)

    app_user = relationship("AppUser", back_populates="performed_session")
    session_schedule = relationship("SessionSchedule", back_populates="performed_session")
    performed_exercise = relationship("PerformedExercise", back_populates="performed_session")


class PerformedExercise(Base):
    __tablename__ = "performed_exercise"
    __table_args__ = (
        ForeignKeyConstraint(
            ["exercise_id"],
            ["exercise.exercise_id"],
            name="performed_exercise_exercise_id_fkey",
        ),
        ForeignKeyConstraint(
            ["performed_session_id"],
            ["performed_session.performed_session_id"],
            name="performed_exercise_performed_session_id_fkey",
        ),
        PrimaryKeyConstraint("performed_exercise_id", name="performed_exercise_pkey"),
    )

    performed_exercise_id = Column(UUID, server_default=text("uuid_generate_v1mc()"))
    performed_session_id = Column(UUID, nullable=False)
    name = Column(Text, nullable=False)
    reps = Column(ARRAY(Integer), nullable=False)
    exercise_id = Column(UUID)
    sets = Column(Integer, Computed("array_length(reps, 1)", persisted=True))
    rest = Column(
        ARRAY(INTERVAL()),
        server_default=text(
            "ARRAY['00:01:00'::interval, '00:01:00'::interval, '00:01:00'::interval, '00:01:00'::interval, '00:01:00'::interval]"
        ),
    )
    weight = Column(Integer)
    started_at = Column(DateTime, server_default=text("now()"))
    completed_at = Column(DateTime, server_default=text("now()"))
    note = Column(Text)
    data = Column(JSONB)

    exercise = relationship("Exercise", back_populates="performed_exercise")
    performed_session = relationship("PerformedSession", back_populates="performed_exercise")
