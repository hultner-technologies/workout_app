/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
import type { PerformedSessionRead } from '../models/PerformedSessionRead';
import type { PerformedSessionReadMany } from '../models/PerformedSessionReadMany';
import type { Plan } from '../models/Plan';
import type { PlanRead } from '../models/PlanRead';
import type { SessionScheduleRead } from '../models/SessionScheduleRead';
import type { SessionScheduleReadNew } from '../models/SessionScheduleReadNew';

import type { CancelablePromise } from '../core/CancelablePromise';
import { OpenAPI } from '../core/OpenAPI';
import { request as __request } from '../core/request';

export class DefaultService {

    /**
     * Read Plans
     * @param offset
     * @param limit
     * @returns Plan Successful Response
     * @throws ApiError
     */
    public static readPlansPlansGet(
        offset?: number,
        limit: number = 100,
    ): CancelablePromise<Array<Plan>> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/plans/',
            query: {
                'offset': offset,
                'limit': limit,
            },
            errors: {
                422: `Validation Error`,
            },
        });
    }

    /**
     * Read Plan
     * @param planId
     * @returns PlanRead Successful Response
     * @throws ApiError
     */
    public static readPlanPlansPlanIdGet(
        planId: string,
    ): CancelablePromise<PlanRead> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/plans/{plan_id}',
            path: {
                'plan_id': planId,
            },
            errors: {
                422: `Validation Error`,
            },
        });
    }

    /**
     * Read Session Schedule
     * @param sessionScheduleId
     * @returns SessionScheduleRead Successful Response
     * @throws ApiError
     */
    public static readSessionScheduleSessionSchedulesSessionScheduleIdGet(
        sessionScheduleId: string,
    ): CancelablePromise<SessionScheduleRead> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/session-schedules/{session_schedule_id}',
            path: {
                'session_schedule_id': sessionScheduleId,
            },
            errors: {
                422: `Validation Error`,
            },
        });
    }

    /**
     * Read Performed Sessions
     * @param offset
     * @param limit
     * @param sessionScheduleId
     * @returns PerformedSessionReadMany Successful Response
     * @throws ApiError
     */
    public static readPerformedSessionsPerformedSessionsGet(
        offset?: number,
        limit: number = 100,
        sessionScheduleId?: string,
    ): CancelablePromise<Array<PerformedSessionReadMany>> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/performed-sessions/',
            query: {
                'offset': offset,
                'limit': limit,
                'session_schedule_id': sessionScheduleId,
            },
            errors: {
                422: `Validation Error`,
            },
        });
    }

    /**
     * Read Performed Session
     * @param performedSessionId
     * @returns PerformedSessionRead Successful Response
     * @throws ApiError
     */
    public static readPerformedSessionPerformedSessionsPerformedSessionIdGet(
        performedSessionId: string,
    ): CancelablePromise<PerformedSessionRead> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/performed-sessions/{performed_session_id}',
            path: {
                'performed_session_id': performedSessionId,
            },
            errors: {
                422: `Validation Error`,
            },
        });
    }

    /**
     * Generate Session New
     * @param sessionScheduleId
     * @returns SessionScheduleReadNew Successful Response
     * @throws ApiError
     */
    public static generateSessionNewSessionSchedulesSessionScheduleIdNewGet(
        sessionScheduleId: string,
    ): CancelablePromise<SessionScheduleReadNew> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/session-schedules/{session_schedule_id}/new',
            path: {
                'session_schedule_id': sessionScheduleId,
            },
            errors: {
                422: `Validation Error`,
            },
        });
    }

}
