/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */

import type { ExerciseNewRead } from './ExerciseNewRead';

export type SessionScheduleReadNew = {
    session_schedule_id: string;
    plan_id: string;
    name: string;
    progression_limit: number;
    description?: string;
    links?: Array<any>;
    data?: any;
    exercise?: Array<ExerciseNewRead>;
};

