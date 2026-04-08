# Drone Crop Swarm

A Next.js application for drone crop management with authentication and analytics.

## Features

- 🔐 Authentication with [Clerk](https://clerk.com/)
- 📊 Analytics with [PostHog](https://posthog.com/)
- ⚡ Built with [Next.js 14](https://nextjs.org/)
- 🎨 Styled with [Tailwind CSS](https://tailwindcss.com/)
- 📝 TypeScript support

## Getting Started

### Prerequisites

- Node.js 18+ installed
- npm or yarn package manager

### Installation

1. Clone the repository:
```bash
git clone https://github.com/kwizzlesurp10-ctrl/Drone_Crop_Swarm.git
cd Drone_Crop_Swarm
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env.local
```

Edit `.env.local` and add your Clerk and PostHog credentials.

### Running the Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

### Building for Production

```bash
npm run build
npm start
```

## Project Structure

```
├── app/
│   ├── layout.tsx        # Root layout with providers
│   ├── page.tsx          # Home page
│   └── globals.css       # Global styles
├── components/
│   └── PostHogProvider.tsx  # PostHog analytics provider
├── public/               # Static assets
└── package.json          # Dependencies
```

## Environment Variables

Required environment variables:

- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` - Clerk publishable key
- `CLERK_SECRET_KEY` - Clerk secret key
- `NEXT_PUBLIC_POSTHOG_KEY` - PostHog project API key
- `NEXT_PUBLIC_POSTHOG_HOST` - PostHog API host (optional, defaults to https://app.posthog.com)

## Learn More

- [Next.js Documentation](https://nextjs.org/docs)
- [Clerk Documentation](https://clerk.com/docs)
- [PostHog Documentation](https://posthog.com/docs)
