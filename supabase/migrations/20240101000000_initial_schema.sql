-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  organization TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create drones table
CREATE TABLE IF NOT EXISTS public.drones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  model TEXT,
  serial_number TEXT UNIQUE,
  status TEXT CHECK (status IN ('active', 'inactive', 'maintenance', 'charging')) DEFAULT 'inactive',
  battery_level NUMERIC(5,2) CHECK (battery_level >= 0 AND battery_level <= 100),
  location GEOGRAPHY(POINT, 4326),
  altitude NUMERIC(10,2),
  owner_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create fields table (agricultural fields)
CREATE TABLE IF NOT EXISTS public.fields (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  boundary GEOGRAPHY(POLYGON, 4326) NOT NULL,
  area_sqm NUMERIC(15,2),
  crop_type TEXT,
  owner_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create missions table
CREATE TABLE IF NOT EXISTS public.missions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  field_id UUID REFERENCES public.fields(id) ON DELETE CASCADE,
  status TEXT CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled')) DEFAULT 'planned',
  mission_type TEXT CHECK (mission_type IN ('survey', 'spray', 'monitor', 'custom')),
  flight_path GEOGRAPHY(LINESTRING, 4326),
  start_time TIMESTAMP WITH TIME ZONE,
  end_time TIMESTAMP WITH TIME ZONE,
  created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create drone_missions junction table (many-to-many)
CREATE TABLE IF NOT EXISTS public.drone_missions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  drone_id UUID REFERENCES public.drones(id) ON DELETE CASCADE,
  mission_id UUID REFERENCES public.missions(id) ON DELETE CASCADE,
  assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(drone_id, mission_id)
);

-- Create telemetry table (drone sensor data)
CREATE TABLE IF NOT EXISTS public.telemetry (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  drone_id UUID REFERENCES public.drones(id) ON DELETE CASCADE,
  location GEOGRAPHY(POINT, 4326) NOT NULL,
  altitude NUMERIC(10,2),
  battery_level NUMERIC(5,2),
  speed NUMERIC(8,2),
  heading NUMERIC(5,2),
  temperature NUMERIC(5,2),
  humidity NUMERIC(5,2),
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create images table
CREATE TABLE IF NOT EXISTS public.images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  mission_id UUID REFERENCES public.missions(id) ON DELETE CASCADE,
  drone_id UUID REFERENCES public.drones(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  thumbnail_url TEXT,
  location GEOGRAPHY(POINT, 4326),
  metadata JSONB,
  captured_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create analysis_results table (AI/ML results)
CREATE TABLE IF NOT EXISTS public.analysis_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  image_id UUID REFERENCES public.images(id) ON DELETE CASCADE,
  analysis_type TEXT CHECK (analysis_type IN ('yolov10', 'sam2', 'combined')),
  detections JSONB,
  segmentation JSONB,
  health_score NUMERIC(5,2) CHECK (health_score >= 0 AND health_score <= 100),
  diseases_detected TEXT[],
  recommendations JSONB,
  processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_drones_location ON public.drones USING GIST(location);
CREATE INDEX idx_drones_owner ON public.drones(owner_id);
CREATE INDEX idx_fields_boundary ON public.fields USING GIST(boundary);
CREATE INDEX idx_fields_owner ON public.fields(owner_id);
CREATE INDEX idx_missions_field ON public.missions(field_id);
CREATE INDEX idx_missions_status ON public.missions(status);
CREATE INDEX idx_telemetry_drone ON public.telemetry(drone_id);
CREATE INDEX idx_telemetry_recorded_at ON public.telemetry(recorded_at DESC);
CREATE INDEX idx_images_mission ON public.images(mission_id);
CREATE INDEX idx_analysis_results_image ON public.analysis_results(image_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_drones_updated_at BEFORE UPDATE ON public.drones
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fields_updated_at BEFORE UPDATE ON public.fields
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_missions_updated_at BEFORE UPDATE ON public.missions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
