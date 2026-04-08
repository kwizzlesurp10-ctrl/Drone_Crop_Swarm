# Drone_Crop_Swarm

An intelligent drone swarm system for precision agriculture and crop management.

## Environment Setup

This project requires several environment variables to be configured. Follow these steps:

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and fill in your actual values for each variable:

### Required Environment Variables

- **NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY**: Your Clerk publishable key for authentication
- **SUPABASE_URL**: Your Supabase project URL
- **SUPABASE_ANON_KEY**: Your Supabase anonymous key for client-side access
- **STRIPE_SECRET_KEY**: Your Stripe secret key for payment processing
- **POSTHOG_KEY**: Your PostHog project API key for analytics
- **XAI_SYMBIOSIS_PERCENT**: AI symbiosis percentage (default: 12)
- **RTK_NTRIP_HOST**: RTK/NTRIP host for GPS corrections (default: rtk.emlid.com)
- **MAPBOX_TOKEN**: Your Mapbox access token for map rendering
- **OPENAI_API_KEY**: Your OpenAI API key (optional, for prompt-based diagnostics)

### Getting API Keys

- **Clerk**: Sign up at [clerk.com](https://clerk.com) and create a new application
- **Supabase**: Create a project at [supabase.com](https://supabase.com)
- **Stripe**: Get your keys from [stripe.com/dashboard](https://dashboard.stripe.com)
- **PostHog**: Sign up at [posthog.com](https://posthog.com)
- **Mapbox**: Create an account at [mapbox.com](https://www.mapbox.com)
- **OpenAI**: Get your API key from [platform.openai.com](https://platform.openai.com)

## Security

**Important**: Never commit your `.env` file to version control. The `.gitignore` file is configured to exclude all `.env` files automatically.
