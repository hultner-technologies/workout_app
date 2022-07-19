/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */

import type { SessionSchedule } from './SessionSchedule';

export type PerformedSessionReadMany = {
    performed_session_id: string;
    session_schedule_id: string;
    app_user_id: string;
    started_at?: string;
    completed_at?: string;
    note?: string;
    data?: any;
    session_schedule?: SessionSchedule;
};

