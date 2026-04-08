'use client';

import { ReactFlowProvider } from '@xyflow/react';
import '@xyflow/react/dist/style.css';

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <div className="z-10 w-full max-w-5xl items-center justify-between font-mono text-sm">
        <h1 className="text-4xl font-bold mb-8">AetherAg Orbit Dashboard</h1>
        <ReactFlowProvider>
          <div className="w-full h-96 border border-gray-300 rounded-lg">
            {/* React Flow dashboard will be implemented here */}
            <p className="p-4">Drone swarm visualization coming soon...</p>
          </div>
        </ReactFlowProvider>
      </div>
    </main>
  );
}
