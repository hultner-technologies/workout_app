/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */

import type { ExerciseRead } from './ExerciseRead';

export type PerformedExerciseRead = {
    performed_exercise_id: string;
    performed_session_id: string;
    name: string;
    reps: Array<any>;
    exercise_id?: string;
    sets?: number;
    rest?: Array<any>;
    weight?: number;
    started_at?: string;
    completed_at?: string;
    note?: string;
    data?: any;
    exercise?: ExerciseRead;
};

