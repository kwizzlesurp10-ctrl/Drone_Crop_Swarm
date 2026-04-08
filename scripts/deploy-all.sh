#!/bin/bash
set -e

echo "🚀 Deploying Drone Crop Swarm..."

# Check if required CLIs are installed
command -v vercel >/dev/null 2>&1 || { echo "❌ Vercel CLI not installed. Run: npm install -g vercel"; exit 1; }
command -v flyctl >/dev/null 2>&1 || { echo "❌ Fly CLI not installed. Run: curl -L https://fly.io/install.sh | sh"; exit 1; }
command -v supabase >/dev/null 2>&1 || { echo "❌ Supabase CLI not installed. Run: npm install -g supabase"; exit 1; }

# Step 1: Deploy Supabase database
echo "📊 Deploying Supabase database schema..."
supabase db push
echo "✅ Database schema deployed"

# Step 2: Deploy Vercel web app
echo "🌐 Deploying web app to Vercel..."
npm run deploy:web
echo "✅ Web app deployed"

# Step 3: Deploy Fly.io GPU workers
echo "🖥️  Deploying GPU workers to Fly.io..."
fly deploy
echo "✅ GPU workers deployed"

echo ""
echo "🎉 All services deployed successfully!"
echo ""
echo "Next steps:"
echo "1. Configure Stripe webhook: https://dashboard.stripe.com/webhooks"
echo "2. Verify PostHog events: https://app.posthog.com"
echo "3. Check Sentry errors: https://sentry.io"
echo "4. Test first login to create Stripe customer"
