# ML Predictive Modeling Implementation Plan

**Date:** 2025-11-21
**Status:** Planning Phase
**Research Basis:** [Phase 2.8 ML Research](../research/phase-2-8-ml-predictive-modeling.md)

---

## Executive Summary

**Goal:** Implement ML-powered workout predictions to differentiate from competitors (Strong, Hevy have zero AI features).

**Approach:** Start with proven Random Forest models (R² > 0.90) using PostgresML for in-database ML, then expand to time series forecasting and anomaly detection.

**Timeline:** 16-20 weeks across 3 phases
**Effort:** 480-680 hours (12-17 weeks at full-time)

**Key Differentiators:**
- ✅ First app with explainable predictions (SHAP values)
- ✅ Research-backed accuracy (cite specific R² values)
- ✅ Rich metadata advantage (muscle-specific predictions)

---

## Phase Overview

```
Phase 1: Foundation (4-6 weeks)
├── PostgresML setup & data pipeline
├── Random Forest 1RM prediction (R² target: >0.90)
└── Isolation Forest anomaly detection

Phase 2: Advanced Analytics (8-12 weeks)
├── LSTM time series forecasting
├── User clustering & percentile rankings
└── Dashboard integration

Phase 3: Intelligent Recommendations (12-16 weeks)
├── Reinforcement learning for workout optimization
├── Continuous training pipelines
└── Production optimization
```

---

## Prerequisites

### Database Requirements
- ✅ V3 analytics views deployed (weekly_exercise_volume, weekly_muscle_volume)
- ✅ Minimum 12-16 weeks of user data for training
- ✅ PostgreSQL 15+ with pgvector extension support

### Infrastructure
- [ ] PostgresML extension installed
- [ ] Python 3.11+ environment for offline training
- [ ] Redis for prediction caching
- [ ] MLflow for model versioning (optional but recommended)

### Team Skills
- PostgreSQL advanced (CTEs, window functions, triggers)
- Python ML libraries (scikit-learn, XGBoost, statsmodels)
- Basic statistics (regression, time series, clustering)
- PostgresML or willingness to learn (good documentation)

---

## Phase 1: Foundation (4-6 weeks, 120-160 hours)

**Goal:** Ship first ML features - 1RM predictions and anomaly detection

### Week 1-2: Infrastructure & Data Pipeline (40-50 hours)

#### 1.1 PostgresML Setup (8-12 hours)
```sql
-- Install PostgresML extension
CREATE EXTENSION IF NOT EXISTS pgml;

-- Verify installation
SELECT pgml.version();

-- Test basic functionality
SELECT * FROM pgml.train(
    'test_model',
    'regression',
    ARRAY['column1', 'column2'],
    'target_column',
    'pgml.dataset'
);
```

**Tasks:**
- [ ] Install PostgresML extension on development database
- [ ] Install PostgresML extension on staging database
- [ ] Test basic training/prediction workflow
- [ ] Document setup process in README
- [ ] Create rollback plan

**Deliverable:** PostgresML operational on dev and staging

#### 1.2 ML Schema Design (12-16 hours)
```sql
-- Schema in migration: database/330_ml_schema.sql

-- Store trained models metadata
CREATE TABLE ml_models (
    model_id UUID PRIMARY KEY DEFAULT uuid_generate_v1mc(),
    model_name TEXT NOT NULL,
    model_type TEXT NOT NULL, -- 'random_forest', 'lstm', 'isolation_forest'
    target_metric TEXT NOT NULL, -- '1rm_prediction', 'anomaly_detection'
    algorithm TEXT NOT NULL, -- 'pgml_random_forest', 'pgml_xgboost'
    training_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_window_start TIMESTAMPTZ NOT NULL,
    data_window_end TIMESTAMPTZ NOT NULL,
    training_samples INTEGER NOT NULL,

    -- Model performance metrics
    accuracy_metrics JSONB NOT NULL, -- {r_squared, rmse, mape, mae}
    feature_importance JSONB, -- Top features with importance scores
    hyperparameters JSONB, -- Model configuration

    -- Metadata
    created_by UUID REFERENCES app_user(user_id),
    is_active BOOLEAN DEFAULT true,
    deployed_at TIMESTAMPTZ,
    deprecated_at TIMESTAMPTZ,

    CONSTRAINT valid_model_type CHECK (model_type IN (
        'random_forest', 'xgboost', 'lstm', 'isolation_forest', 'kmeans'
    )),
    CONSTRAINT valid_target CHECK (target_metric IN (
        '1rm_prediction', 'next_weight', 'plateau_risk',
        'anomaly_detection', 'user_segmentation'
    ))
);

CREATE INDEX idx_ml_models_active ON ml_models(model_type, target_metric) WHERE is_active = true;
CREATE INDEX idx_ml_models_deployed ON ml_models(deployed_at DESC) WHERE is_active = true;

-- Store predictions
CREATE TABLE ml_predictions (
    prediction_id UUID PRIMARY KEY DEFAULT uuid_generate_v1mc(),
    user_id UUID NOT NULL REFERENCES app_user(user_id),
    exercise_id UUID REFERENCES exercise(exercise_id),
    model_id UUID NOT NULL REFERENCES ml_models(model_id),

    prediction_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    prediction_type TEXT NOT NULL,
    prediction_horizon TEXT, -- '1_week', '4_weeks', '12_weeks'

    -- Prediction values
    predicted_value NUMERIC NOT NULL,
    confidence_score NUMERIC CHECK (confidence_score >= 0 AND confidence_score <= 1),
    prediction_lower_bound NUMERIC, -- 95% confidence interval
    prediction_upper_bound NUMERIC,

    -- Context
    features_used JSONB NOT NULL, -- Snapshot of input features
    shap_values JSONB, -- Explainability (feature contributions)

    -- Actuals for validation
    actual_value NUMERIC,
    actual_recorded_at TIMESTAMPTZ,
    prediction_error NUMERIC, -- Calculated: actual - predicted

    CONSTRAINT valid_prediction_type CHECK (prediction_type IN (
        'next_weight', '1rm_forecast', 'volume_forecast', 'plateau_risk'
    )),
    CONSTRAINT valid_horizon CHECK (prediction_horizon IN (
        '1_session', '1_week', '4_weeks', '12_weeks', '26_weeks'
    ))
);

CREATE INDEX idx_ml_predictions_user ON ml_predictions(user_id, prediction_date DESC);
CREATE INDEX idx_ml_predictions_exercise ON ml_predictions(exercise_id, prediction_date DESC);
CREATE INDEX idx_ml_predictions_validation ON ml_predictions(user_id, exercise_id)
    WHERE actual_value IS NULL;

-- Store anomalies
CREATE TABLE ml_anomalies (
    anomaly_id UUID PRIMARY KEY DEFAULT uuid_generate_v1mc(),
    user_id UUID NOT NULL REFERENCES app_user(user_id),
    model_id UUID NOT NULL REFERENCES ml_models(model_id),

    detection_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    anomaly_type TEXT NOT NULL,
    severity TEXT NOT NULL,
    anomaly_score NUMERIC NOT NULL, -- Higher = more anomalous

    -- Context
    description TEXT NOT NULL,
    recommended_action TEXT,
    affected_exercise_id UUID REFERENCES exercise(exercise_id),
    affected_session_id UUID REFERENCES performed_session(performed_session_id),

    -- User interaction
    user_acknowledged BOOLEAN DEFAULT false,
    user_dismissed BOOLEAN DEFAULT false,
    acknowledged_at TIMESTAMPTZ,

    CONSTRAINT valid_anomaly_type CHECK (anomaly_type IN (
        'volume_spike', 'volume_drop', 'performance_decline',
        'excessive_frequency', 'muscle_imbalance', 'overtraining_risk'
    )),
    CONSTRAINT valid_severity CHECK (severity IN ('info', 'warning', 'caution', 'critical'))
);

CREATE INDEX idx_ml_anomalies_user ON ml_anomalies(user_id, detection_date DESC);
CREATE INDEX idx_ml_anomalies_active ON ml_anomalies(user_id)
    WHERE user_acknowledged = false AND user_dismissed = false;

COMMENT ON TABLE ml_models IS 'Metadata for all trained ML models';
COMMENT ON TABLE ml_predictions IS 'User-specific predictions with confidence scores and explainability';
COMMENT ON TABLE ml_anomalies IS 'Detected anomalies requiring user attention';
```

**Tasks:**
- [ ] Create migration 330_ml_schema.sql
- [ ] Write tests for schema constraints
- [ ] Document schema design decisions
- [ ] Add RLS policies for ml_predictions and ml_anomalies

**Deliverable:** ML schema deployed to dev database

#### 1.3 Feature Engineering Views (20-22 hours)
```sql
-- Create training data view for 1RM prediction
-- Migration: database/335_ml_training_features.sql

CREATE MATERIALIZED VIEW ml_training_features_1rm AS
WITH user_history AS (
    SELECT
        user_id,
        exercise_id,
        week_start,
        max_weight_kg,
        estimated_1rm_kg,
        total_volume_kg,
        working_sets,
        avg_reps,
        avg_rir,

        -- Time-based features
        ROW_NUMBER() OVER (PARTITION BY user_id, exercise_id ORDER BY week_start) AS week_number,
        EXTRACT(DAYS FROM week_start - MIN(week_start) OVER (PARTITION BY user_id, exercise_id)) AS days_training,

        -- Lag features (previous week)
        LAG(max_weight_kg, 1) OVER (PARTITION BY user_id, exercise_id ORDER BY week_start) AS prev_week_weight,
        LAG(total_volume_kg, 1) OVER (PARTITION BY user_id, exercise_id ORDER BY week_start) AS prev_week_volume,
        LAG(working_sets, 1) OVER (PARTITION BY user_id, exercise_id ORDER BY week_start) AS prev_week_sets,

        -- Rolling averages (4-week window)
        AVG(max_weight_kg) OVER (
            PARTITION BY user_id, exercise_id
            ORDER BY week_start
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS ma_4week_weight,

        AVG(total_volume_kg) OVER (
            PARTITION BY user_id, exercise_id
            ORDER BY week_start
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS ma_4week_volume,

        -- Progress rate (last 4 weeks)
        CASE
            WHEN LAG(max_weight_kg, 4) OVER (PARTITION BY user_id, exercise_id ORDER BY week_start) IS NOT NULL
            THEN (max_weight_kg - LAG(max_weight_kg, 4) OVER (PARTITION BY user_id, exercise_id ORDER BY week_start))
                 / NULLIF(LAG(max_weight_kg, 4) OVER (PARTITION BY user_id, exercise_id ORDER BY week_start), 0) * 100
            ELSE NULL
        END AS progress_rate_4week_pct

    FROM weekly_exercise_volume
),
exercise_metadata AS (
    SELECT
        e.exercise_id,
        be.mechanic,
        be.force,
        be.level,
        -- Count primary muscles (compound exercises have multiple)
        COUNT(DISTINCT bepm.muscle_group_id) AS primary_muscle_count
    FROM exercise e
    JOIN base_exercise be ON e.base_exercise_id = be.base_exercise_id
    LEFT JOIN base_exercise_primary_muscle bepm ON be.base_exercise_id = bepm.base_exercise_id
    GROUP BY e.exercise_id, be.mechanic, be.force, be.level
)
SELECT
    uh.user_id,
    uh.exercise_id,
    uh.week_start,
    uh.week_number,
    uh.days_training,

    -- Current week features
    uh.max_weight_kg AS current_weight,
    uh.total_volume_kg AS current_volume,
    uh.working_sets AS current_sets,
    uh.avg_reps AS current_reps,
    uh.avg_rir AS current_rir,

    -- Historical features
    uh.prev_week_weight,
    uh.prev_week_volume,
    uh.prev_week_sets,
    uh.ma_4week_weight,
    uh.ma_4week_volume,
    uh.progress_rate_4week_pct,

    -- Exercise metadata features
    em.mechanic AS exercise_mechanic,
    em.force AS exercise_force,
    em.level AS exercise_level,
    em.primary_muscle_count,

    -- Target variable (next week's weight)
    LEAD(uh.max_weight_kg, 1) OVER (PARTITION BY uh.user_id, uh.exercise_id ORDER BY uh.week_start) AS target_next_weight,

    -- Target variable (4-week ahead 1RM)
    LEAD(uh.estimated_1rm_kg, 4) OVER (PARTITION BY uh.user_id, uh.exercise_id ORDER BY uh.week_start) AS target_1rm_4weeks

FROM user_history uh
JOIN exercise_metadata em ON uh.exercise_id = em.exercise_id
WHERE uh.week_number >= 4  -- Need at least 4 weeks of history for features
;

CREATE INDEX idx_ml_training_features_1rm_user
    ON ml_training_features_1rm(user_id, exercise_id, week_start DESC);

COMMENT ON MATERIALIZED VIEW ml_training_features_1rm IS
    'Training features for 1RM prediction model. Includes lag features, moving averages,
     progress rates, and exercise metadata. Refreshed weekly after new data.';
```

**Tasks:**
- [ ] Create ml_training_features_1rm materialized view
- [ ] Create ml_training_features_anomaly view (volume spike detection)
- [ ] Add refresh strategy (weekly or after new sessions)
- [ ] Write tests validating feature calculations
- [ ] Document feature engineering decisions

**Deliverable:** Feature views ready for model training

---

### Week 3-4: Random Forest 1RM Prediction (40-50 hours)

#### 1.4 Model Training Script (20-24 hours)
```python
# scripts/ml/train_1rm_model.py

import asyncpg
import json
from datetime import datetime

async def train_1rm_model():
    """
    Train Random Forest model for 1RM prediction using PostgresML
    """
    conn = await asyncpg.connect(DATABASE_URL)

    # 1. Train model using PostgresML
    train_query = """
    SELECT pgml.train(
        project_name => '1rm_prediction',
        task => 'regression',
        relation_name => 'ml_training_features_1rm',
        y_column_name => 'target_next_weight',
        algorithm => 'random_forest',
        hyperparams => '{
            "n_estimators": 100,
            "max_depth": 10,
            "min_samples_split": 5,
            "random_state": 42
        }'::jsonb,
        test_size => 0.2,
        test_sampling => 'random'
    );
    """

    result = await conn.fetchval(train_query)
    print(f"Training complete. Model ID: {result}")

    # 2. Get model metrics
    metrics_query = """
    SELECT
        project_name,
        algorithm,
        r_squared,
        mean_squared_error,
        mean_absolute_error
    FROM pgml.models
    WHERE project_name = '1rm_prediction'
    ORDER BY created_at DESC
    LIMIT 1;
    """

    metrics = await conn.fetchrow(metrics_query)
    print(f"Model Performance:")
    print(f"  R² = {metrics['r_squared']:.4f}")
    print(f"  RMSE = {metrics['mean_squared_error']**0.5:.2f} kg")
    print(f"  MAE = {metrics['mean_absolute_error']:.2f} kg")

    # 3. Store model metadata in ml_models table
    insert_model_query = """
    INSERT INTO ml_models (
        model_name, model_type, target_metric, algorithm,
        data_window_start, data_window_end, training_samples,
        accuracy_metrics, hyperparameters
    )
    SELECT
        '1rm_prediction_v1',
        'random_forest',
        '1rm_prediction',
        'pgml_random_forest',
        MIN(week_start)::timestamptz,
        MAX(week_start)::timestamptz,
        COUNT(*),
        jsonb_build_object(
            'r_squared', $1::numeric,
            'rmse', $2::numeric,
            'mae', $3::numeric
        ),
        '{
            "n_estimators": 100,
            "max_depth": 10,
            "min_samples_split": 5
        }'::jsonb
    FROM ml_training_features_1rm
    WHERE target_next_weight IS NOT NULL
    RETURNING model_id;
    """

    model_id = await conn.fetchval(
        insert_model_query,
        metrics['r_squared'],
        metrics['mean_squared_error']**0.5,
        metrics['mean_absolute_error']
    )

    print(f"Model metadata stored: {model_id}")

    # 4. Get feature importance
    importance_query = """
    SELECT
        feature_name,
        importance
    FROM pgml.feature_importances('1rm_prediction')
    ORDER BY importance DESC
    LIMIT 10;
    """

    importances = await conn.fetch(importance_query)
    print("\nTop 10 Features:")
    for row in importances:
        print(f"  {row['feature_name']}: {row['importance']:.4f}")

    await conn.close()
    return model_id

if __name__ == "__main__":
    import asyncio
    asyncio.run(train_1rm_model())
```

**Tasks:**
- [ ] Write training script with PostgresML
- [ ] Add validation splits (80/20 train/test)
- [ ] Implement hyperparameter tuning (grid search)
- [ ] Add feature importance extraction
- [ ] Log metrics to ml_models table
- [ ] Write unit tests for training pipeline

**Deliverable:** Training script with R² > 0.90 on test set

#### 1.5 Prediction API Endpoint (20-26 hours)
```python
# app/api/v3/predictions.py

from fastapi import APIRouter, HTTPException
from typing import Optional
import asyncpg

router = APIRouter(prefix="/api/v3/predictions", tags=["predictions"])

@router.get("/next-weight/{exercise_id}")
async def predict_next_weight(
    exercise_id: str,
    user_id: str,  # From auth context
    weeks_ahead: int = 1
):
    """
    Predict next workout weight for an exercise

    Returns:
        - predicted_weight_kg: Predicted weight
        - confidence: Confidence score (0-1)
        - explanation: SHAP-based explanation
        - recommendation: Suggested sets/reps
    """

    conn = await asyncpg.connect(DATABASE_URL)

    # 1. Get latest features for this user/exercise
    features_query = """
    SELECT
        current_weight,
        current_volume,
        current_sets,
        current_reps,
        prev_week_weight,
        ma_4week_weight,
        progress_rate_4week_pct,
        exercise_mechanic,
        days_training
    FROM ml_training_features_1rm
    WHERE user_id = $1
      AND exercise_id = $2
    ORDER BY week_start DESC
    LIMIT 1;
    """

    features = await conn.fetchrow(features_query, user_id, exercise_id)

    if not features:
        raise HTTPException(status_code=404, detail="Insufficient training data")

    # 2. Make prediction using PostgresML
    prediction_query = """
    SELECT pgml.predict(
        '1rm_prediction',
        ARRAY[
            $1::real,  -- current_weight
            $2::real,  -- current_volume
            $3::real,  -- current_sets
            $4::real,  -- current_reps
            $5::real,  -- prev_week_weight
            $6::real,  -- ma_4week_weight
            $7::real,  -- progress_rate_4week_pct
            $8::real,  -- days_training
            -- One-hot encoded exercise_mechanic
            CASE WHEN $9 = 'compound' THEN 1.0 ELSE 0.0 END
        ]
    ) AS predicted_weight;
    """

    predicted_weight = await conn.fetchval(
        prediction_query,
        features['current_weight'],
        features['current_volume'],
        features['current_sets'],
        features['current_reps'],
        features['prev_week_weight'] or features['current_weight'],
        features['ma_4week_weight'],
        features['progress_rate_4week_pct'] or 0,
        features['days_training'],
        features['exercise_mechanic']
    )

    # 3. Calculate confidence score (based on prediction stability)
    # Simple heuristic: higher confidence if consistent progress
    confidence = min(0.95, 0.7 + abs(features['progress_rate_4week_pct'] or 0) / 50)

    # 4. Generate explanation
    explanation = generate_explanation(features, predicted_weight)

    # 5. Store prediction
    store_query = """
    INSERT INTO ml_predictions (
        user_id, exercise_id, model_id, prediction_type,
        prediction_horizon, predicted_value, confidence_score,
        features_used
    )
    SELECT
        $1::uuid, $2::uuid,
        (SELECT model_id FROM ml_models WHERE model_name = '1rm_prediction_v1' AND is_active = true),
        'next_weight',
        $3,
        $4,
        $5,
        $6::jsonb
    RETURNING prediction_id;
    """

    prediction_id = await conn.fetchval(
        store_query,
        user_id,
        exercise_id,
        f"{weeks_ahead}_week",
        predicted_weight,
        confidence,
        json.dumps(dict(features))
    )

    await conn.close()

    return {
        "prediction_id": prediction_id,
        "predicted_weight_kg": round(predicted_weight, 1),
        "confidence": round(confidence, 2),
        "explanation": explanation,
        "recommendation": {
            "sets": features['current_sets'],
            "reps": features['current_reps'],
            "notes": "Aim for 2-3 RIR for optimal progress"
        }
    }

def generate_explanation(features, predicted_weight):
    """Generate human-readable explanation"""

    progress_rate = features['progress_rate_4week_pct'] or 0

    if progress_rate > 3:
        trend = "strong positive"
    elif progress_rate > 0:
        trend = "steady"
    elif progress_rate < -3:
        trend = "declining"
    else:
        trend = "stable"

    return (
        f"Based on your {trend} progress over the last 4 weeks "
        f"({progress_rate:+.1f}% change), we predict you'll lift "
        f"{predicted_weight:.1f} kg next session. "
        f"Your moving average is {features['ma_4week_weight']:.1f} kg."
    )
```

**Tasks:**
- [ ] Create FastAPI endpoint for predictions
- [ ] Add authentication and authorization
- [ ] Implement confidence score calculation
- [ ] Generate SHAP-based explanations (or simplified version)
- [ ] Store predictions in ml_predictions table
- [ ] Add rate limiting (prevent prediction spam)
- [ ] Write integration tests

**Deliverable:** `/api/v3/predictions/next-weight/{exercise_id}` endpoint live

---

### Week 5-6: Isolation Forest Anomaly Detection (40-50 hours)

#### 1.6 Anomaly Detection Model (24-30 hours)

```sql
-- Training query for Isolation Forest
SELECT pgml.train(
    project_name => 'volume_anomaly_detection',
    task => 'classification',  -- Actually unsupervised, but PostgresML treats anomaly detection as classification
    relation_name => 'ml_training_features_anomaly',
    algorithm => 'isolation_forest',
    hyperparams => '{
        "n_estimators": 100,
        "contamination": 0.05,
        "random_state": 42
    }'::jsonb
);
```

```python
# scripts/ml/detect_anomalies.py

async def detect_anomalies_for_user(user_id: str):
    """
    Run anomaly detection on user's recent training data
    """
    conn = await asyncpg.connect(DATABASE_URL)

    # 1. Get user's last 4 weeks of data
    data_query = """
    SELECT
        user_id,
        week_start,
        total_volume_kg,
        working_sets,
        -- Week-over-week changes
        (total_volume_kg - LAG(total_volume_kg) OVER (ORDER BY week_start))
            / NULLIF(LAG(total_volume_kg) OVER (ORDER BY week_start), 0) * 100 AS volume_change_pct,
        (working_sets - LAG(working_sets) OVER (ORDER BY week_start))
            / NULLIF(LAG(working_sets) OVER (ORDER BY week_start), 0) * 100 AS sets_change_pct
    FROM (
        SELECT
            user_id,
            week_start,
            SUM(total_volume_kg) AS total_volume_kg,
            SUM(working_sets) AS working_sets
        FROM weekly_muscle_volume
        WHERE user_id = $1
          AND week_start >= CURRENT_DATE - INTERVAL '4 weeks'
        GROUP BY user_id, week_start
    ) weekly_totals
    ORDER BY week_start DESC;
    """

    data = await conn.fetch(data_query, user_id)

    # 2. Check for volume spikes (simple rule-based for MVP)
    anomalies = []

    for row in data:
        if row['volume_change_pct'] and row['volume_change_pct'] > 20:
            anomalies.append({
                'type': 'volume_spike',
                'severity': 'warning',
                'score': row['volume_change_pct'],
                'description': f"Volume increased {row['volume_change_pct']:.1f}% this week (safe max: 15%)",
                'action': "Consider reducing volume by 2-3 sets next session"
            })

        if row['volume_change_pct'] and row['volume_change_pct'] < -15:
            anomalies.append({
                'type': 'volume_drop',
                'severity': 'info',
                'score': abs(row['volume_change_pct']),
                'description': f"Volume decreased {abs(row['volume_change_pct']):.1f}% this week",
                'action': "Check if this was an intentional deload"
            })

    # 3. Store anomalies
    for anomaly in anomalies:
        insert_query = """
        INSERT INTO ml_anomalies (
            user_id, model_id, anomaly_type, severity, anomaly_score,
            description, recommended_action
        )
        SELECT
            $1::uuid,
            (SELECT model_id FROM ml_models WHERE model_name = 'volume_anomaly_v1' AND is_active = true),
            $2, $3, $4, $5, $6
        RETURNING anomaly_id;
        """

        await conn.execute(
            insert_query,
            user_id,
            anomaly['type'],
            anomaly['severity'],
            anomaly['score'],
            anomaly['description'],
            anomaly['action']
        )

    await conn.close()
    return anomalies
```

**Tasks:**
- [ ] Create anomaly detection training features view
- [ ] Train Isolation Forest model (or use rule-based for MVP)
- [ ] Implement detection script (run nightly)
- [ ] Add anomaly types: volume_spike, volume_drop, performance_decline
- [ ] Create API endpoint: `GET /api/v3/predictions/anomalies`
- [ ] Add user acknowledgment flow
- [ ] Write tests for anomaly detection

**Deliverable:** Anomaly detection system alerting users to risky training patterns

---

## Phase 2: Advanced Analytics (8-12 weeks, 200-280 hours)

**Goal:** Add time series forecasting, user clustering, and dashboard integration

### Week 7-10: LSTM Time Series Forecasting (80-100 hours)

#### 2.1 LSTM Model Training (40-50 hours)

This will likely be done in Python (not PostgresML) due to complexity:

```python
# scripts/ml/train_lstm.py

import tensorflow as tf
from tensorflow import keras
import numpy as np

def prepare_sequences(data, sequence_length=12):
    """
    Prepare sequences for LSTM training
    sequence_length: number of weeks to look back
    """
    X, y = [], []
    for i in range(len(data) - sequence_length):
        X.append(data[i:i+sequence_length])
        y.append(data[i+sequence_length])
    return np.array(X), np.array(y)

def build_lstm_model(input_shape):
    """
    Build LSTM model for time series forecasting
    """
    model = keras.Sequential([
        keras.layers.LSTM(64, return_sequences=True, input_shape=input_shape),
        keras.layers.Dropout(0.2),
        keras.layers.LSTM(32),
        keras.layers.Dropout(0.2),
        keras.layers.Dense(16, activation='relu'),
        keras.layers.Dense(1)  # Predict next value
    ])

    model.compile(
        optimizer='adam',
        loss='mse',
        metrics=['mae']
    )

    return model

async def train_lstm_1rm_forecast():
    """
    Train LSTM model for multi-week 1RM forecasting
    """
    # 1. Load training data from PostgreSQL
    conn = await asyncpg.connect(DATABASE_URL)

    data_query = """
    SELECT
        user_id,
        exercise_id,
        week_start,
        estimated_1rm_kg,
        total_volume_kg,
        working_sets,
        avg_reps
    FROM weekly_exercise_volume
    WHERE week_start >= CURRENT_DATE - INTERVAL '2 years'
    ORDER BY user_id, exercise_id, week_start;
    """

    data = await conn.fetch(data_query)
    await conn.close()

    # 2. Prepare sequences (12 weeks lookback)
    # Group by user/exercise and create sequences
    sequences = {}
    for row in data:
        key = (row['user_id'], row['exercise_id'])
        if key not in sequences:
            sequences[key] = []
        sequences[key].append([
            row['estimated_1rm_kg'],
            row['total_volume_kg'],
            row['working_sets'],
            row['avg_reps']
        ])

    # 3. Create training data
    X_train, y_train = [], []
    for key, seq in sequences.items():
        if len(seq) >= 13:  # Need at least 13 weeks (12 + 1 target)
            X, y = prepare_sequences(seq, sequence_length=12)
            X_train.extend(X)
            y_train.extend(y[:, 0])  # Only predict 1RM

    X_train = np.array(X_train)
    y_train = np.array(y_train)

    # 4. Train model
    model = build_lstm_model(input_shape=(12, 4))

    history = model.fit(
        X_train, y_train,
        epochs=50,
        batch_size=32,
        validation_split=0.2,
        callbacks=[
            keras.callbacks.EarlyStopping(patience=5, restore_best_weights=True)
        ]
    )

    # 5. Evaluate
    val_loss, val_mae = model.evaluate(X_train, y_train)
    print(f"Validation MAE: {val_mae:.2f} kg")

    # 6. Save model
    model.save('models/lstm_1rm_forecast_v1.h5')

    return model

if __name__ == "__main__":
    import asyncio
    asyncio.run(train_lstm_1rm_forecast())
```

**Tasks:**
- [ ] Set up TensorFlow/PyTorch environment
- [ ] Prepare sequence data (12-week lookback)
- [ ] Build LSTM architecture
- [ ] Train model with early stopping
- [ ] Evaluate on test set (target: MAPE < 10%)
- [ ] Save model and load in FastAPI
- [ ] Create prediction endpoint: `GET /api/v3/predictions/1rm-forecast?weeks=12`

**Deliverable:** LSTM model predicting 4-12 weeks ahead with <10% MAPE

#### 2.2 Dashboard Integration (40-50 hours)

```typescript
// Example React Native component for predictions

import React, { useEffect, useState } from 'react';
import { View, Text, ActivityIndicator } from 'react-native';
import { LineChart } from 'react-native-chart-kit';

interface Prediction {
  predicted_weight_kg: number;
  confidence: number;
  explanation: string;
  week: string;
}

export const PredictionChart: React.FC<{ exerciseId: string }> = ({ exerciseId }) => {
  const [predictions, setPredictions] = useState<Prediction[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchPredictions = async () => {
      const response = await fetch(
        `/api/v3/predictions/1rm-forecast/${exerciseId}?weeks=12`
      );
      const data = await response.json();
      setPredictions(data.predictions);
      setLoading(false);
    };

    fetchPredictions();
  }, [exerciseId]);

  if (loading) return <ActivityIndicator />;

  return (
    <View>
      <Text style={{ fontSize: 18, fontWeight: 'bold' }}>
        Predicted Progress (12 weeks)
      </Text>
      <LineChart
        data={{
          labels: predictions.map(p => p.week),
          datasets: [{
            data: predictions.map(p => p.predicted_weight_kg),
            strokeWidth: 2,
            color: (opacity = 1) => `rgba(75, 192, 192, ${opacity})`
          }]
        }}
        width={350}
        height={220}
        chartConfig={{
          backgroundColor: '#ffffff',
          backgroundGradientFrom: '#ffffff',
          backgroundGradientTo: '#ffffff',
          decimalPlaces: 1,
          color: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`
        }}
      />
      <Text style={{ fontSize: 14, color: '#666', marginTop: 8 }}>
        {predictions[0].explanation}
      </Text>
      <Text style={{ fontSize: 12, color: '#999' }}>
        Confidence: {(predictions[0].confidence * 100).toFixed(0)}%
      </Text>
    </View>
  );
};
```

**Tasks:**
- [ ] Design prediction dashboard UI/UX
- [ ] Implement chart components (historical + forecast)
- [ ] Add confidence indicators
- [ ] Show SHAP explanations (simplified)
- [ ] Add anomaly alerts to home screen
- [ ] User testing with beta group

**Deliverable:** Predictions integrated into mobile app

---

### Week 11-14: User Clustering & Percentile Rankings (80-120 hours)

#### 2.3 K-Means Clustering (40-60 hours)

```sql
-- Train clustering model
SELECT pgml.train(
    project_name => 'user_segmentation',
    task => 'clustering',
    relation_name => 'user_training_profiles',
    algorithm => 'kmeans',
    hyperparams => '{
        "n_clusters": 5,
        "random_state": 42
    }'::jsonb
);

-- User profiles for clustering
CREATE MATERIALIZED VIEW user_training_profiles AS
SELECT
    user_id,
    -- Training volume features
    AVG(total_sets) AS avg_weekly_sets,
    STDDEV(total_sets) AS volume_variability,

    -- Progress features
    AVG(progress_rate_4week_pct) AS avg_progress_rate,

    -- Training age proxy
    COUNT(DISTINCT week_start) AS weeks_training,

    -- Exercise preferences
    SUM(CASE WHEN exercise_mechanic = 'compound' THEN working_sets ELSE 0 END)
        / NULLIF(SUM(working_sets), 0) AS compound_preference,

    -- Consistency
    COUNT(DISTINCT DATE_TRUNC('week', performed_at))
        / EXTRACT(WEEKS FROM MAX(performed_at) - MIN(performed_at)) AS training_frequency
FROM weekly_exercise_volume wev
JOIN performed_session ps ON wev.user_id = ps.user_id
WHERE wev.week_start >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY user_id
HAVING COUNT(DISTINCT week_start) >= 12;  -- Minimum 12 weeks of data
```

**Tasks:**
- [ ] Create user_training_profiles view
- [ ] Train K-means clustering (5 clusters)
- [ ] Assign cluster labels to users
- [ ] Create cluster descriptions (e.g., "Fast Progressors", "High Volume Trainers")
- [ ] Calculate percentile rankings within clusters
- [ ] API endpoint: `GET /api/v3/predictions/user-percentile/{exercise_id}`

**Deliverable:** "You're in the 85th percentile for intermediate lifters" feature

#### 2.4 Comparative Analytics (40-60 hours)

```python
@router.get("/user-percentile/{exercise_id}")
async def get_user_percentile(
    exercise_id: str,
    user_id: str  # From auth
):
    """
    Get user's percentile ranking compared to similar users
    """
    conn = await asyncpg.connect(DATABASE_URL)

    # 1. Get user's cluster
    cluster_query = """
    SELECT cluster_id
    FROM user_clusters
    WHERE user_id = $1;
    """
    cluster_id = await conn.fetchval(cluster_query, user_id)

    # 2. Get user's current 1RM
    user_1rm_query = """
    SELECT MAX(estimated_1rm_kg) AS current_1rm
    FROM weekly_exercise_volume
    WHERE user_id = $1 AND exercise_id = $2
      AND week_start >= CURRENT_DATE - INTERVAL '4 weeks';
    """
    user_1rm = await conn.fetchval(user_1rm_query, user_id, exercise_id)

    # 3. Calculate percentile within cluster
    percentile_query = """
    WITH cluster_users AS (
        SELECT
            wev.user_id,
            MAX(wev.estimated_1rm_kg) AS max_1rm
        FROM weekly_exercise_volume wev
        JOIN user_clusters uc ON wev.user_id = uc.user_id
        WHERE uc.cluster_id = $1
          AND wev.exercise_id = $2
          AND wev.week_start >= CURRENT_DATE - INTERVAL '4 weeks'
        GROUP BY wev.user_id
    )
    SELECT
        PERCENT_RANK() OVER (ORDER BY max_1rm) * 100 AS percentile,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY max_1rm) AS median_1rm,
        MIN(max_1rm) AS min_1rm,
        MAX(max_1rm) AS max_1rm,
        COUNT(*) AS comparison_group_size
    FROM cluster_users
    WHERE user_id = $3;
    """

    stats = await conn.fetchrow(percentile_query, cluster_id, exercise_id, user_id)

    await conn.close()

    return {
        "percentile": round(stats['percentile'], 0),
        "your_1rm_kg": user_1rm,
        "median_1rm_kg": stats['median_1rm'],
        "min_1rm_kg": stats['min_1rm'],
        "max_1rm_kg": stats['max_1rm'],
        "comparison_group_size": stats['comparison_group_size'],
        "cluster_description": get_cluster_description(cluster_id),
        "message": f"You're stronger than {stats['percentile']:.0f}% of similar lifters"
    }
```

**Tasks:**
- [ ] Implement percentile calculation
- [ ] Create cluster descriptions
- [ ] Add comparison group sizes
- [ ] Design percentile UI component
- [ ] Add "Users like you" insights

**Deliverable:** Comparative analytics showing user progress vs peers

---

## Phase 3: Intelligent Recommendations (12-16 weeks, 160-240 hours)

**Goal:** Reinforcement learning for workout optimization and continuous training

### Week 15-16: Reinforcement Learning Setup (80-120 hours)

#### 3.1 Contextual Bandits for Workout Recommendations (40-60 hours)

```python
# Simplified contextual bandits approach
# Full RL (A3C) can come later

from sklearn.ensemble import RandomForestClassifier

class WorkoutRecommendationSystem:
    """
    Contextual bandits approach to recommend optimal volume/intensity
    """

    def __init__(self):
        self.models = {
            'volume': RandomForestClassifier(),
            'intensity': RandomForestClassifier()
        }
        self.actions = {
            'volume': ['increase_10pct', 'maintain', 'decrease_10pct'],
            'intensity': ['increase_weight', 'maintain_weight', 'decrease_weight']
        }

    def get_context(self, user_id, exercise_id):
        """
        Get user's current training context
        """
        # Features: current volume, progress rate, fatigue markers
        return {
            'current_volume': ...,
            'progress_rate': ...,
            'weeks_since_deload': ...,
            'rir_average': ...
        }

    def recommend_action(self, context):
        """
        Recommend volume/intensity adjustment
        """
        volume_probs = self.models['volume'].predict_proba([context])[0]
        volume_action = self.actions['volume'][np.argmax(volume_probs)]

        intensity_probs = self.models['intensity'].predict_proba([context])[0]
        intensity_action = self.actions['intensity'][np.argmax(intensity_probs)]

        return {
            'volume_recommendation': volume_action,
            'intensity_recommendation': intensity_action,
            'confidence': max(volume_probs)
        }

    def update_model(self, context, action, reward):
        """
        Update model based on observed reward (progress made)
        """
        # Reward = progress made in next 2-4 weeks
        # Positive if user progressed, negative if plateaued/regressed
        pass
```

**Tasks:**
- [ ] Implement contextual bandits framework
- [ ] Define actions (volume increase/decrease, intensity adjustments)
- [ ] Define rewards (progress made, injury avoidance)
- [ ] Collect initial training data from historical decisions
- [ ] Train initial policy
- [ ] API endpoint: `GET /api/v3/recommendations/next-adjustment`

**Deliverable:** Basic RL system recommending volume/intensity adjustments

#### 3.2 Continuous Training Pipelines (40-60 hours)

```python
# Airflow DAG for continuous model training

from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'ml_team',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email_on_failure': True,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'ml_model_retraining',
    default_args=default_args,
    description='Weekly ML model retraining pipeline',
    schedule_interval='@weekly',
    catchup=False
)

def refresh_training_views():
    """Refresh materialized views with latest data"""
    conn = asyncpg.connect(DATABASE_URL)
    conn.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY ml_training_features_1rm;")
    conn.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY user_training_profiles;")
    conn.close()

def retrain_1rm_model():
    """Retrain Random Forest model"""
    # Run training script
    import scripts.ml.train_1rm_model as train
    new_model_id = train.train_1rm_model()

    # If new model is better, deploy it
    # Otherwise keep current model

def retrain_clustering():
    """Retrain user clustering"""
    import scripts.ml.train_clustering as cluster
    cluster.train_kmeans()

def evaluate_models():
    """Evaluate all active models on recent data"""
    # Calculate prediction errors for last week
    # Alert if model performance degrades

refresh_views_task = PythonOperator(
    task_id='refresh_training_views',
    python_callable=refresh_training_views,
    dag=dag
)

retrain_1rm_task = PythonOperator(
    task_id='retrain_1rm_model',
    python_callable=retrain_1rm_model,
    dag=dag
)

retrain_clustering_task = PythonOperator(
    task_id='retrain_clustering',
    python_callable=retrain_clustering,
    dag=dag
)

evaluate_task = PythonOperator(
    task_id='evaluate_models',
    python_callable=evaluate_models,
    dag=dag
)

# Task dependencies
refresh_views_task >> [retrain_1rm_task, retrain_clustering_task] >> evaluate_task
```

**Tasks:**
- [ ] Set up Airflow (or similar orchestration)
- [ ] Create weekly retraining DAG
- [ ] Implement model versioning
- [ ] Add A/B testing framework
- [ ] Monitor model drift
- [ ] Automated rollback on performance degradation

**Deliverable:** Automated model retraining pipeline

#### 3.3 Production Optimization (40-60 hours)

**Tasks:**
- [ ] Add Redis caching for predictions (cache for 1 day)
- [ ] Optimize slow queries (add missing indexes)
- [ ] Implement batch prediction endpoints
- [ ] Add monitoring/alerting (Prometheus + Grafana)
- [ ] Load testing (target: <500ms p99 latency)
- [ ] Create ML operations dashboard

**Deliverable:** Production-ready ML system with <500ms latency

---

## Success Metrics

### Technical Metrics

**Model Performance:**
- [ ] 1RM prediction R² > 0.90 (target from research)
- [ ] LSTM forecast MAPE < 10%
- [ ] Anomaly detection precision > 80% (minimize false positives)
- [ ] API latency p95 < 500ms

**System Health:**
- [ ] Model retraining success rate > 95%
- [ ] Prediction cache hit rate > 70%
- [ ] Zero data loss incidents
- [ ] Weekly model evaluation reports

### Product Metrics

**User Engagement:**
- [ ] 40%+ of users view predictions (first month)
- [ ] 60%+ of users view predictions (after 3 months)
- [ ] <5% prediction opt-out rate
- [ ] User feedback: 4+ stars for prediction accuracy

**Business Impact:**
- [ ] 15%+ increase in user retention (compared to control)
- [ ] 20%+ increase in session frequency
- [ ] Competitive differentiation validated (user surveys)
- [ ] Premium feature conversion rate (if monetized)

### Safety Metrics

**Injury Prevention:**
- [ ] Anomaly alert acknowledgment rate > 70%
- [ ] Zero reported injuries attributed to predictions
- [ ] Conservative prediction bias maintained (under-predict by 5-10%)

---

## Risk Mitigation

### Technical Risks

**Risk: Insufficient training data**
- **Mitigation:** Require minimum 12-16 weeks per user before predictions
- **Fallback:** Show population-based predictions for new users

**Risk: Model drift over time**
- **Mitigation:** Weekly retraining pipeline with automated evaluation
- **Fallback:** Automated rollback to previous model version

**Risk: PostgresML performance issues**
- **Mitigation:** Extensive load testing before launch
- **Fallback:** Pre-compute predictions overnight, cache in Redis

### Product Risks

**Risk: Users distrust AI predictions**
- **Mitigation:** Add SHAP explanations, show confidence scores
- **Fallback:** Make predictions opt-in initially

**Risk: Inaccurate predictions harm user trust**
- **Mitigation:** Conservative predictions (under-predict by 5-10%)
- **Fallback:** Clear disclaimers, focus on trends not exact values

### Safety Risks

**Risk: Predictions encourage overtraining**
- **Mitigation:** Anomaly detection alerts before predictions
- **Fallback:** Reduce predicted weights if anomalies detected

**Risk: Liability concerns**
- **Mitigation:** Legal disclaimers, terms of service updates
- **Fallback:** Consult legal team before launch

---

## Next Steps

### Immediate Actions (Before Phase 1 Starts)

1. [ ] Review and approve this plan
2. [ ] Set up development environment (PostgresML, Python 3.11+)
3. [ ] Verify V3 analytics views are deployed and working
4. [ ] Identify beta users (target: 50-100 users with 16+ weeks of data)
5. [ ] Create project board with tasks from this plan

### Iteration Points

This plan will be iterated on:
- **After Week 2:** Review infrastructure setup, adjust Week 3-4 tasks
- **After Week 6:** Evaluate 1RM model performance, decide LSTM priority
- **After Week 10:** User feedback session, adjust Phase 2 priorities
- **After Week 14:** Decide on RL vs simpler recommendation heuristics

---

## Appendix: Tool Comparison

### PostgresML vs External Python

**PostgresML Advantages:**
- ✅ 8-40X faster inference (no network latency)
- ✅ No data movement (training happens in-database)
- ✅ Supports 50+ algorithms (Random Forest, XGBoost, linear models)
- ✅ Zero infrastructure overhead

**External Python Advantages:**
- ✅ More ML libraries available (Prophet, custom LSTM architectures)
- ✅ Easier debugging and experimentation
- ✅ Better integration with MLflow, TensorBoard
- ✅ Team may be more familiar with Python ML stack

**Recommendation:** Use PostgresML for production models (Random Forest, XGBoost), Python for experimental models (LSTM, RL)

---

**Plan Status:** Ready for Review
**Next Action:** Schedule planning session to iterate on priorities
