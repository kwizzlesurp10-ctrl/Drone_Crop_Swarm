import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  transpilePackages: ['@aetherag-orbit/ui', '@aetherag-orbit/geospatial'],
  experimental: {
    turbo: {
      resolveAlias: {
        '@/*': './src/*',
      },
    },
  },
};

export default nextConfig;
