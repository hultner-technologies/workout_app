from datetime import datetime, timedelta
from decimal import Decimal
from typing import List, Optional

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
from sqlmodel import Field, Relationship, SQLModel


class AppUser(SQLModel, table=True):
    __tablename__ = "app_user"
    __table_args__ = (PrimaryKeyConstraint("app_user_id", name="app_user_pkey"),)

    app_user_id: str = Field(
        sa_column=Column(
            "app_user_id", UUID, server_default=text("uuid_generate_v1mc()")
        )
    )
    name: str = Field(sa_column=Column("name", Text, nullable=False))
    email: str = Field(sa_column=Column("email", Text, nullable=False))
    password: Optional[str] = Field(default=None, sa_column=Column("password", Text))
    data: Optional[dict] = Field(default=None, sa_column=Column("data", JSONB))

    performed_session: List["PerformedSession"] = Relationship(
        back_populates="app_user"
    )


class BaseExercise(SQLModel, table=True):
    __tablename__ = "base_exercise"
    __table_args__ = (
        PrimaryKeyConstraint("base_exercise_id", name="base_exercise_pkey"),
    )

    base_exercise_id: str = Field(
        sa_column=Column(
            "base_exercise_id", UUID, server_default=text("uuid_generate_v1mc()")
        )
    )
    name: str = Field(sa_column=Column("name", Text, nullable=False))
    description: Optional[str] = Field(
        default=None, sa_column=Column("description", Text)
    )
    links: Optional[list] = Field(
        default=None, sa_column=Column("links", ARRAY(Text()))
    )
    data: Optional[dict] = Field(default=None, sa_column=Column("data", JSONB))

    exercise: List["Exercise"] = Relationship(back_populates="base_exercise")


class Plan(SQLModel, table=True):
    __tablename__ = "plan"
    __table_args__ = (PrimaryKeyConstraint("plan_id", name="plan_pkey"),)

    plan_id: str = Field(
        sa_column=Column("plan_id", UUID, server_default=text("uuid_generate_v1mc()"))
    )
    name: str = Field(sa_column=Column("name", Text, nullable=False))
    description: Optional[str] = Field(
        default=None, sa_column=Column("description", Text)
    )
    links: Optional[list] = Field(
        default=None, sa_column=Column("links", ARRAY(Text()))
    )
    data: Optional[dict] = Field(default=None, sa_column=Column("data", JSONB))

    session_schedule: List["SessionSchedule"] = Relationship(back_populates="plan")


class SessionSchedule(SQLModel, table=True):
    __tablename__ = "session_schedule"
    __table_args__ = (
        CheckConstraint(
            "(progression_limit > (0)::numeric) AND (progression_limit < (1)::numeric)",
            name="session_schedule_progression_limit_check",
        ),
        ForeignKeyConstraint(
            ["plan_id"], ["plan.plan_id"], name="session_schedule_plan_id_fkey"
        ),
        PrimaryKeyConstraint("session_schedule_id", name="session_schedule_pkey"),
    )

    session_schedule_id: str = Field(
        sa_column=Column(
            "session_schedule_id", UUID, server_default=text("uuid_generate_v1mc()")
        )
    )
    plan_id: str = Field(sa_column=Column("plan_id", UUID, nullable=False))
    name: str = Field(sa_column=Column("name", Text, nullable=False))
    progression_limit: Decimal = Field(
        sa_column=Column("progression_limit", Numeric(2, 1), nullable=False, server_default=text("(1)::numeric"))
    )
    description: Optional[str] = Field(
        default=None, sa_column=Column("description", Text)
    )
    links: Optional[list] = Field(
        default=None, sa_column=Column("links", ARRAY(Text()))
    )
    data: Optional[dict] = Field(default=None, sa_column=Column("data", JSONB))

    plan: Optional["Plan"] = Relationship(back_populates="session_schedule")
    exercise: List["Exercise"] = Relationship(back_populates="session_schedule")
    performed_session: List["PerformedSession"] = Relationship(
        back_populates="session_schedule"
    )


class Exercise(SQLModel, table=True):
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

    exercise_id: str = Field(
        sa_column=Column(
            "exercise_id", UUID, server_default=text("uuid_generate_v1mc()")
        )
    )
    base_exercise_id: str = Field(
        sa_column=Column("base_exercise_id", UUID, nullable=False)
    )
    session_schedule_id: str = Field(
        sa_column=Column("session_schedule_id", UUID, nullable=False)
    )
    reps: int = Field(
        sa_column=Column("reps", Integer, nullable=False, server_default=text("10"))
    )
    sets: int = Field(
        sa_column=Column("sets", Integer, nullable=False, server_default=text("5"))
    )
    rest: timedelta = Field(
        sa_column=Column(
            "rest",
            INTERVAL,
            nullable=False,
            server_default=text("'00:01:00'::interval"),
        )
    )
    data: Optional[dict] = Field(default=None, sa_column=Column("data", JSONB))

    base_exercise: Optional["BaseExercise"] = Relationship(back_populates="exercise")
    session_schedule: Optional["SessionSchedule"] = Relationship(
        back_populates="exercise"
    )
    performed_exercise: List["PerformedExercise"] = Relationship(
        back_populates="exercise"
    )


class PerformedSession(SQLModel, table=True):
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

    performed_session_id: str = Field(
        sa_column=Column(
            "performed_session_id", UUID, server_default=text("uuid_generate_v1mc()")
        )
    )
    session_schedule_id: str = Field(
        sa_column=Column("session_schedule_id", UUID, nullable=False)
    )
    app_user_id: str = Field(sa_column=Column("app_user_id", UUID, nullable=False))
    started_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("started_at", DateTime, server_default=text("now()")),
    )
    completed_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("completed_at", DateTime, server_default=text("now()")),
    )
    note: Optional[str] = Field(default=None, sa_column=Column("note", Text))
    data: Optional[dict] = Field(default=None, sa_column=Column("data", JSONB))

    app_user: Optional["AppUser"] = Relationship(back_populates="performed_session")
    session_schedule: Optional["SessionSchedule"] = Relationship(
        back_populates="performed_session"
    )
    performed_exercise: List["PerformedExercise"] = Relationship(
        back_populates="performed_session"
    )


class PerformedExercise(SQLModel, table=True):
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

    performed_exercise_id: str = Field(
        sa_column=Column(
            "performed_exercise_id", UUID, server_default=text("uuid_generate_v1mc()")
        )
    )
    performed_session_id: str = Field(
        sa_column=Column("performed_session_id", UUID, nullable=False)
    )
    name: str = Field(sa_column=Column("name", Text, nullable=False))
    reps: int = Field(sa_column=Column("reps", Integer, nullable=False))
    exercise_id: Optional[str] = Field(
        default=None, sa_column=Column("exercise_id", UUID)
    )
    sets: Optional[int] = Field(
        default=None,
        sa_column=Column(
            "sets", Integer, Computed("array_length(reps, 1)", persisted=True)
        ),
    )
    rest: Optional[list] = Field(
        default=None,
        sa_column=Column(
            "rest",
            ARRAY(INTERVAL()),
            server_default=text(
                "ARRAY['00:01:00'::interval, '00:01:00'::interval, '00:01:00'::interval, '00:01:00'::interval, '00:01:00'::interval]"
            ),
        ),
    )
    weight: Optional[int] = Field(default=None, sa_column=Column("weight", Integer))
    started_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("started_at", DateTime, server_default=text("now()")),
    )
    completed_at: Optional[datetime] = Field(
        default=None,
        sa_column=Column("completed_at", DateTime, server_default=text("now()")),
    )
    note: Optional[str] = Field(default=None, sa_column=Column("note", Text))
    data: Optional[dict] = Field(default=None, sa_column=Column("data", JSONB))

    exercise: Optional["Exercise"] = Relationship(back_populates="performed_exercise")
    performed_session: Optional["PerformedSession"] = Relationship(
        back_populates="performed_exercise"
    )
