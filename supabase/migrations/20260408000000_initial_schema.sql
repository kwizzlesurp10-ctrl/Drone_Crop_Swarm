-- Enable PostGIS extension for geospatial operations
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Farms table
CREATE TABLE IF NOT EXISTS public.farms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    location GEOGRAPHY(POINT, 4326),
    boundary GEOGRAPHY(POLYGON, 4326),
    area_hectares NUMERIC(10, 2),
    stripe_customer_id TEXT,
    stripe_subscription_id TEXT,
    subscription_status TEXT DEFAULT 'trial'
);

-- Enable Row Level Security
ALTER TABLE public.farms ENABLE ROW LEVEL SECURITY;

-- RLS Policies for farms
CREATE POLICY "Users can view their own farms"
    ON public.farms FOR SELECT
    USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert their own farms"
    ON public.farms FOR INSERT
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own farms"
    ON public.farms FOR UPDATE
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own farms"
    ON public.farms FOR DELETE
    USING (auth.uid() = owner_id);

-- Drones table
CREATE TABLE IF NOT EXISTS public.drones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    farm_id UUID NOT NULL REFERENCES public.farms(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    model TEXT,
    status TEXT DEFAULT 'idle',
    current_location GEOGRAPHY(POINT, 4326),
    battery_level INTEGER,
    last_seen TIMESTAMPTZ
);

ALTER TABLE public.drones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view drones for their farms"
    ON public.drones FOR SELECT
    USING (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

CREATE POLICY "Users can insert drones for their farms"
    ON public.drones FOR INSERT
    WITH CHECK (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

CREATE POLICY "Users can update drones for their farms"
    ON public.drones FOR UPDATE
    USING (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

CREATE POLICY "Users can delete drones for their farms"
    ON public.drones FOR DELETE
    USING (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

-- Missions table
CREATE TABLE IF NOT EXISTS public.missions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    farm_id UUID NOT NULL REFERENCES public.farms(id) ON DELETE CASCADE,
    drone_id UUID REFERENCES public.drones(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    mission_type TEXT NOT NULL,
    status TEXT DEFAULT 'planned',
    planned_route GEOGRAPHY(LINESTRING, 4326),
    actual_route GEOGRAPHY(LINESTRING, 4326),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
);

ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view missions for their farms"
    ON public.missions FOR SELECT
    USING (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

CREATE POLICY "Users can insert missions for their farms"
    ON public.missions FOR INSERT
    WITH CHECK (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

CREATE POLICY "Users can update missions for their farms"
    ON public.missions FOR UPDATE
    USING (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

CREATE POLICY "Users can delete missions for their farms"
    ON public.missions FOR DELETE
    USING (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

-- Images table for drone captured imagery
CREATE TABLE IF NOT EXISTS public.images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    mission_id UUID NOT NULL REFERENCES public.missions(id) ON DELETE CASCADE,
    farm_id UUID NOT NULL REFERENCES public.farms(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    capture_location GEOGRAPHY(POINT, 4326),
    altitude_meters NUMERIC(8, 2),
    processed BOOLEAN DEFAULT FALSE,
    analysis_results JSONB
);

ALTER TABLE public.images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view images for their farms"
    ON public.images FOR SELECT
    USING (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

CREATE POLICY "Users can insert images for their farms"
    ON public.images FOR INSERT
    WITH CHECK (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

CREATE POLICY "Users can update images for their farms"
    ON public.images FOR UPDATE
    USING (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

CREATE POLICY "Users can delete images for their farms"
    ON public.images FOR DELETE
    USING (farm_id IN (SELECT id FROM public.farms WHERE owner_id = auth.uid()));

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_farms_updated_at BEFORE UPDATE ON public.farms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_drones_updated_at BEFORE UPDATE ON public.drones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_missions_updated_at BEFORE UPDATE ON public.missions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for better performance
CREATE INDEX idx_farms_owner_id ON public.farms(owner_id);
CREATE INDEX idx_drones_farm_id ON public.drones(farm_id);
CREATE INDEX idx_missions_farm_id ON public.missions(farm_id);
CREATE INDEX idx_missions_drone_id ON public.missions(drone_id);
CREATE INDEX idx_images_farm_id ON public.images(farm_id);
CREATE INDEX idx_images_mission_id ON public.images(mission_id);
CREATE INDEX idx_farms_location ON public.farms USING GIST(location);
CREATE INDEX idx_drones_location ON public.drones USING GIST(current_location);
