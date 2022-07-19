/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */

import type { SessionScheduleRead } from './SessionScheduleRead';

export type PlanRead = {
    plan_id: string;
    name: string;
    description?: string;
    links?: Array<any>;
    data?: any;
    session_schedule?: Array<SessionScheduleRead>;
};

