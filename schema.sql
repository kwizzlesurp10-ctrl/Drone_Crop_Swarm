-- Drone Crop Swarm Database Schema
-- PostGIS enabled for geospatial operations
-- Multi-tenant architecture with Row Level Security (RLS)

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Farms table (main tenant entity)
CREATE TABLE farms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  location GEOGRAPHY(POINT, 4326),
  boundary GEOGRAPHY(POLYGON, 4326),
  owner_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on farms
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see their own farms
CREATE POLICY farms_isolation_policy ON farms
  USING (owner_id = current_setting('app.current_user_id')::UUID);

-- Drone Assets table
CREATE TABLE drone_assets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
  model VARCHAR(255) NOT NULL,
  serial_number VARCHAR(255) UNIQUE NOT NULL,
  status VARCHAR(50) DEFAULT 'active',
  battery_level NUMERIC(5,2),
  last_location GEOGRAPHY(POINT, 4326),
  firmware_version VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on drone_assets
ALTER TABLE drone_assets ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see drones for their farms
CREATE POLICY drone_assets_isolation_policy ON drone_assets
  USING (farm_id IN (SELECT id FROM farms WHERE owner_id = current_setting('app.current_user_id')::UUID));

-- Patrol Missions table
CREATE TABLE patrol_missions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
  drone_id UUID REFERENCES drone_assets(id) ON DELETE SET NULL,
  mission_name VARCHAR(255) NOT NULL,
  flight_path GEOGRAPHY(LINESTRING, 4326),
  planned_area GEOGRAPHY(POLYGON, 4326),
  status VARCHAR(50) DEFAULT 'planned',
  scheduled_start TIMESTAMPTZ,
  actual_start TIMESTAMPTZ,
  actual_end TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on patrol_missions
ALTER TABLE patrol_missions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see missions for their farms
CREATE POLICY patrol_missions_isolation_policy ON patrol_missions
  USING (farm_id IN (SELECT id FROM farms WHERE owner_id = current_setting('app.current_user_id')::UUID));

-- Imagery Captures table
CREATE TABLE imagery_captures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  mission_id UUID REFERENCES patrol_missions(id) ON DELETE CASCADE,
  drone_id UUID REFERENCES drone_assets(id) ON DELETE SET NULL,
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  thumbnail_url TEXT,
  capture_location GEOGRAPHY(POINT, 4326),
  altitude_meters NUMERIC(10,2),
  capture_time TIMESTAMPTZ NOT NULL,
  image_type VARCHAR(50), -- e.g., 'RGB', 'NDVI', 'thermal'
  resolution_mpx NUMERIC(10,2),
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on imagery_captures
ALTER TABLE imagery_captures ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see imagery for their farms
CREATE POLICY imagery_captures_isolation_policy ON imagery_captures
  USING (farm_id IN (SELECT id FROM farms WHERE owner_id = current_setting('app.current_user_id')::UUID));

-- AI Diagnostics table
CREATE TABLE ai_diagnostics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  image_id UUID REFERENCES imagery_captures(id) ON DELETE CASCADE,
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
  diagnostic_type VARCHAR(100) NOT NULL, -- e.g., 'pest_detection', 'disease_detection', 'crop_health'
  confidence_score NUMERIC(5,4), -- 0.0000 to 1.0000
  findings JSONB, -- Detailed findings from AI analysis
  affected_area GEOGRAPHY(POLYGON, 4326),
  severity VARCHAR(50), -- e.g., 'low', 'medium', 'high', 'critical'
  recommendations TEXT,
  processed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on ai_diagnostics
ALTER TABLE ai_diagnostics ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see diagnostics for their farms
CREATE POLICY ai_diagnostics_isolation_policy ON ai_diagnostics
  USING (farm_id IN (SELECT id FROM farms WHERE owner_id = current_setting('app.current_user_id')::UUID));

-- Prescription Maps table
CREATE TABLE prescription_maps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
  diagnostic_id UUID REFERENCES ai_diagnostics(id) ON DELETE SET NULL,
  map_name VARCHAR(255) NOT NULL,
  map_type VARCHAR(100), -- e.g., 'fertilizer', 'pesticide', 'irrigation'
  prescription_data JSONB, -- Detailed prescription zones and rates
  coverage_area GEOGRAPHY(POLYGON, 4326),
  status VARCHAR(50) DEFAULT 'draft', -- e.g., 'draft', 'approved', 'applied'
  valid_from TIMESTAMPTZ,
  valid_until TIMESTAMPTZ,
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on prescription_maps
ALTER TABLE prescription_maps ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see prescription maps for their farms
CREATE POLICY prescription_maps_isolation_policy ON prescription_maps
  USING (farm_id IN (SELECT id FROM farms WHERE owner_id = current_setting('app.current_user_id')::UUID));

-- xAI Symbiosis Contributions table (event logging)
CREATE TABLE symbiosis_contributions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL,
  percent NUMERIC DEFAULT 12,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on symbiosis_contributions
ALTER TABLE symbiosis_contributions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see contributions for their farms
CREATE POLICY symbiosis_contributions_isolation_policy ON symbiosis_contributions
  USING (farm_id IN (SELECT id FROM farms WHERE owner_id = current_setting('app.current_user_id')::UUID));

-- Indexes for performance optimization
CREATE INDEX idx_farms_owner_id ON farms(owner_id);
CREATE INDEX idx_farms_location ON farms USING GIST(location);
CREATE INDEX idx_farms_boundary ON farms USING GIST(boundary);

CREATE INDEX idx_drone_assets_farm_id ON drone_assets(farm_id);
CREATE INDEX idx_drone_assets_status ON drone_assets(status);
CREATE INDEX idx_drone_assets_location ON drone_assets USING GIST(last_location);

CREATE INDEX idx_patrol_missions_farm_id ON patrol_missions(farm_id);
CREATE INDEX idx_patrol_missions_drone_id ON patrol_missions(drone_id);
CREATE INDEX idx_patrol_missions_status ON patrol_missions(status);
CREATE INDEX idx_patrol_missions_scheduled_start ON patrol_missions(scheduled_start);

CREATE INDEX idx_imagery_captures_mission_id ON imagery_captures(mission_id);
CREATE INDEX idx_imagery_captures_farm_id ON imagery_captures(farm_id);
CREATE INDEX idx_imagery_captures_capture_time ON imagery_captures(capture_time);
CREATE INDEX idx_imagery_captures_location ON imagery_captures USING GIST(capture_location);

CREATE INDEX idx_ai_diagnostics_image_id ON ai_diagnostics(image_id);
CREATE INDEX idx_ai_diagnostics_farm_id ON ai_diagnostics(farm_id);
CREATE INDEX idx_ai_diagnostics_type ON ai_diagnostics(diagnostic_type);
CREATE INDEX idx_ai_diagnostics_severity ON ai_diagnostics(severity);

CREATE INDEX idx_prescription_maps_farm_id ON prescription_maps(farm_id);
CREATE INDEX idx_prescription_maps_diagnostic_id ON prescription_maps(diagnostic_id);
CREATE INDEX idx_prescription_maps_status ON prescription_maps(status);

CREATE INDEX idx_symbiosis_contributions_farm_id ON symbiosis_contributions(farm_id);
CREATE INDEX idx_symbiosis_contributions_created_at ON symbiosis_contributions(created_at);
