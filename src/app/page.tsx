'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { posthog } from '@/lib/posthog'

export default function Home() {
  const [user, setUser] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Check active sessions and sets the user
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null)
      setLoading(false)

      // Track user in PostHog
      if (session?.user) {
        posthog.identify(session.user.id, {
          email: session.user.email,
        })

        // Trigger onboarding for first-time users
        handleFirstLogin(session.user.id, session.user.email!)
      }
    })

    // Listen for changes on auth state
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)

      if (session?.user) {
        posthog.identify(session.user.id, {
          email: session.user.email,
        })
      }
    })

    return () => subscription.unsubscribe()
  }, [])

  async function handleFirstLogin(userId: string, email: string) {
    try {
      const response = await fetch('/api/onboarding', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ userId, email }),
      })

      const data = await response.json()

      if (data.success && !data.existing) {
        posthog.capture('stripe_customer_created', {
          customerId: data.customerId,
          productId: data.productId,
        })
      }
    } catch (error) {
      console.error('Onboarding error:', error)
    }
  }

  if (loading) {
    return <div>Loading...</div>
  }

  return (
    <main style={{ padding: '2rem' }}>
      <h1>Drone Crop Swarm</h1>
      {user ? (
        <div>
          <p>Welcome, {user.email}!</p>
          <button onClick={() => supabase.auth.signOut()}>Sign Out</button>
        </div>
      ) : (
        <div>
          <p>Please sign in to continue</p>
          <button onClick={() => supabase.auth.signInWithOAuth({ provider: 'google' })}>
            Sign In with Google
          </button>
        </div>
      )}
    </main>
  )
}
