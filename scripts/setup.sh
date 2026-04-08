#!/bin/bash

echo "🔧 Setting up Drone Crop Swarm development environment..."

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "❌ Node.js 20+ required. Current version: $(node -v)"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Check if .env.local exists
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local from .env.example..."
    cp .env.example .env.local
    echo "⚠️  Please update .env.local with your actual credentials"
fi

# Install CLIs if not present
echo "🔨 Checking for required CLIs..."

if ! command -v vercel &> /dev/null; then
    echo "Installing Vercel CLI..."
    npm install -g vercel
fi

if ! command -v supabase &> /dev/null; then
    echo "Installing Supabase CLI..."
    npm install -g supabase
fi

if ! command -v flyctl &> /dev/null; then
    echo "⚠️  Fly CLI not found. Install with: curl -L https://fly.io/install.sh | sh"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env.local with your credentials"
echo "2. Run 'npm run dev' to start development server"
echo "3. Run 'supabase start' for local database"
echo ""
