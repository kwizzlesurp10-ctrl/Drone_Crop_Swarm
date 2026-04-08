# AetherAg Orbit 🚁

> AI-powered precision agriculture platform with autonomous drone swarm management

[![CI/CD](https://github.com/username/aetherag-orbit/actions/workflows/deploy.yml/badge.svg)](https://github.com/username/aetherag-orbit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

AetherAg Orbit is a comprehensive full-stack platform for managing agricultural drone swarms with real-time telemetry, AI-powered plant diagnostics (YOLOv10 + SAM2), and geospatial analytics powered by PostGIS and Mapbox.

## 🏗️ Architecture

```
aetherag-orbit/
├── apps/
│   ├── web/                  # Next.js 16.2.1 frontend + React Flow dashboard
│   └── api/                  # FastAPI 0.115.0 backend
├── packages/
│   ├── ui/                   # shadcn/ui + Tailwind v4 components
│   ├── geospatial/           # PostGIS + Mapbox utilities
│   └── ai/                   # YOLOv10 + SAM2 type definitions
├── supabase/
│   └── migrations/           # Database schema + RLS policies
├── docker-compose.yml
├── turbo.json
└── package.json
```

## ✨ Features

- 🎯 **Real-time Drone Tracking**: Live telemetry and location tracking with React Flow visualization
- 🌾 **Precision Agriculture**: AI-powered crop health analysis using YOLOv10 and SAM2
- 🗺️ **Geospatial Analytics**: PostGIS-powered field mapping and mission planning with Mapbox
- 🚀 **Mission Management**: Plan, execute, and monitor autonomous drone missions
- 📊 **Analytics Dashboard**: Comprehensive insights into field health and drone performance
- 🔐 **Secure Authentication**: Supabase Auth with Row Level Security (RLS)
- 📱 **Responsive Design**: shadcn/ui components with Tailwind CSS v4

## 🛠️ Tech Stack

### Frontend
- **Framework**: Next.js 16.2.1 (React 19)
- **Styling**: Tailwind CSS v4
- **UI Components**: shadcn/ui
- **Visualization**: React Flow
- **Maps**: Mapbox GL JS
- **State Management**: Zustand
- **Auth**: Supabase Auth

### Backend
- **Framework**: FastAPI 0.115.0
- **Database**: PostgreSQL 16 + PostGIS
- **ORM**: SQLAlchemy + asyncpg
- **AI/ML**: YOLOv10, SAM2, PyTorch
- **Authentication**: JWT with python-jose

### Infrastructure
- **Monorepo**: Turborepo
- **Containerization**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Hosting**: Configurable (Vercel, AWS, GCP, etc.)

## 🚀 Quick Start

### Prerequisites

- Node.js 20+ and npm 10+
- Python 3.11+
- Docker and Docker Compose
- Supabase account (or local Supabase setup)
- Mapbox account for mapping features

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/username/aetherag-orbit.git
   cd aetherag-orbit
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Install dependencies**
   ```bash
   npm install
   ```

4. **Start the development environment**
   ```bash
   docker-compose up -d
   ```

5. **Run database migrations**
   ```bash
   # Apply Supabase migrations
   npx supabase db push
   ```

6. **Start the development servers**
   ```bash
   npm run dev
   ```

   The services will be available at:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Docs: http://localhost:8000/docs

## 📦 Project Structure

### Apps

#### `apps/web` - Next.js Frontend
- Modern React 19 with Next.js 16.2.1
- Server Components and App Router
- React Flow for drone swarm visualization
- Mapbox integration for geospatial features

#### `apps/api` - FastAPI Backend
- RESTful API with automatic OpenAPI documentation
- Async database operations with SQLAlchemy
- AI/ML model integration (YOLOv10, SAM2)
- Real-time telemetry processing

### Packages

#### `packages/ui`
Shared UI components built with shadcn/ui and Tailwind CSS v4
- Button, Card, and other reusable components
- Consistent design system across the platform

#### `packages/geospatial`
Geospatial utilities and helpers
- Distance calculations
- Area computations
- Point-in-polygon checks
- Grid generation for mission planning

#### `packages/ai`
TypeScript type definitions for AI models
- YOLOv10 detection types
- SAM2 segmentation types
- Analysis request/response interfaces

## 🗄️ Database Schema

The database is managed by Supabase with PostGIS extension:

- **users**: User profiles and authentication
- **drones**: Drone fleet management
- **fields**: Agricultural field boundaries and metadata
- **missions**: Mission planning and execution
- **telemetry**: Real-time drone sensor data
- **images**: Captured imagery from missions
- **analysis_results**: AI/ML analysis results

See `supabase/migrations/` for complete schema definitions.

## 🔐 Security

- Row Level Security (RLS) policies enforce data access control
- JWT-based authentication
- HTTPS enforced in production
- Environment variables for sensitive configuration
- Regular security audits via GitHub Actions

## 🧪 Testing

```bash
# Run all tests
npm test

# Frontend tests
npm test --workspace=@aetherag-orbit/web

# Backend tests
cd apps/api && pytest
```

## 📝 API Documentation

Interactive API documentation is available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 🚢 Deployment

See [DEPLOY.md](./DEPLOY.md) for detailed deployment instructions.

Quick deployment options:
- **Frontend**: Vercel, Netlify, AWS Amplify
- **Backend**: Railway, Render, AWS ECS, Google Cloud Run
- **Database**: Supabase (managed), AWS RDS, Google Cloud SQL

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Next.js](https://nextjs.org/) - React framework
- [FastAPI](https://fastapi.tiangolo.com/) - Modern Python web framework
- [Supabase](https://supabase.com/) - Open source Firebase alternative
- [Mapbox](https://www.mapbox.com/) - Mapping platform
- [Ultralytics](https://github.com/ultralytics/ultralytics) - YOLOv10 implementation
- [Meta AI](https://github.com/facebookresearch/segment-anything-2) - SAM2 segmentation model

## 📧 Contact

For questions or support, please open an issue or contact [your-email@example.com](mailto:your-email@example.com).

---

Built with ❤️ for precision agriculture