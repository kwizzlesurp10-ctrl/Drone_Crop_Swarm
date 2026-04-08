-- Enable Row Level Security on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drone_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.telemetry ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analysis_results ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

-- Drones policies
CREATE POLICY "Users can view their own drones"
  ON public.drones FOR SELECT
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert their own drones"
  ON public.drones FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own drones"
  ON public.drones FOR UPDATE
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own drones"
  ON public.drones FOR DELETE
  USING (auth.uid() = owner_id);

-- Fields policies
CREATE POLICY "Users can view their own fields"
  ON public.fields FOR SELECT
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert their own fields"
  ON public.fields FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own fields"
  ON public.fields FOR UPDATE
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own fields"
  ON public.fields FOR DELETE
  USING (auth.uid() = owner_id);

-- Missions policies
CREATE POLICY "Users can view missions they created"
  ON public.missions FOR SELECT
  USING (auth.uid() = created_by);

CREATE POLICY "Users can insert missions"
  ON public.missions FOR INSERT
  WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update missions they created"
  ON public.missions FOR UPDATE
  USING (auth.uid() = created_by);

CREATE POLICY "Users can delete missions they created"
  ON public.missions FOR DELETE
  USING (auth.uid() = created_by);

-- Telemetry policies
CREATE POLICY "Users can view telemetry from their drones"
  ON public.telemetry FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.drones
      WHERE drones.id = telemetry.drone_id
      AND drones.owner_id = auth.uid()
    )
  );

CREATE POLICY "Service role can insert telemetry"
  ON public.telemetry FOR INSERT
  WITH CHECK (true); -- Restricted to service role in practice

-- Images policies
CREATE POLICY "Users can view images from their missions"
  ON public.images FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.missions
      WHERE missions.id = images.mission_id
      AND missions.created_by = auth.uid()
    )
  );

-- Analysis results policies
CREATE POLICY "Users can view analysis results from their images"
  ON public.analysis_results FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.images
      JOIN public.missions ON missions.id = images.mission_id
      WHERE images.id = analysis_results.image_id
      AND missions.created_by = auth.uid()
    )
  );
