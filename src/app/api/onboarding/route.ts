import { NextResponse } from 'next/server'
import { supabaseAdmin } from '@/lib/supabase'
import { createStripeCustomerAndProduct } from '@/lib/stripe'
import { Sentry } from '@/lib/sentry'

export async function POST(request: Request) {
  try {
    const { userId, email } = await request.json()

    if (!userId || !email) {
      return NextResponse.json(
        { error: 'Missing userId or email' },
        { status: 400 }
      )
    }

    // Check if user already has Stripe customer
    const { data: farms } = await supabaseAdmin
      .from('farms')
      .select('stripe_customer_id')
      .eq('owner_id', userId)
      .single()

    // If user already has a Stripe customer, return
    if (farms?.stripe_customer_id) {
      return NextResponse.json({
        success: true,
        existing: true,
        customerId: farms.stripe_customer_id
      })
    }

    // Create Stripe customer and product on first login
    const { customerId, productId, priceId } = await createStripeCustomerAndProduct(
      userId,
      email
    )

    // Update or create farm with Stripe customer ID
    const { error: updateError } = await supabaseAdmin
      .from('farms')
      .upsert({
        owner_id: userId,
        stripe_customer_id: customerId,
        name: 'Default Farm',
        subscription_status: 'trial'
      }, {
        onConflict: 'owner_id'
      })

    if (updateError) {
      throw updateError
    }

    return NextResponse.json({
      success: true,
      customerId,
      productId,
      priceId,
      message: 'Stripe customer and product created successfully'
    })
  } catch (error) {
    console.error('Error in onboarding:', error)
    Sentry.captureException(error)
    return NextResponse.json(
      { error: 'Failed to complete onboarding' },
      { status: 500 }
    )
  }
}
