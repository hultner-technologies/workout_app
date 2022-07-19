/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */

import type { BaseExercise } from './BaseExercise';

export type ExerciseNewRead = {
    exercise_id: string;
    base_exercise_id: string;
    session_schedule_id: string;
    reps: number;
    sets: number;
    rest: number;
    sort_order: number;
    data?: any;
    base_exercise: BaseExercise;
    weight?: number;
};

