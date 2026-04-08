'use client'

import { useEffect } from 'react'
import { initPostHog } from '@/lib/posthog'
import { initSentry } from '@/lib/sentry'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  useEffect(() => {
    // Initialize monitoring tools
    initPostHog()
    initSentry()
  }, [])

  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
