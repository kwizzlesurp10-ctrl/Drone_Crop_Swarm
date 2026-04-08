import { NextResponse } from 'next/server'
import { stripe } from '@/lib/stripe'
import { supabaseAdmin } from '@/lib/supabase'
import { Sentry } from '@/lib/sentry'

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!

export async function POST(request: Request) {
  try {
    const body = await request.text()
    const signature = request.headers.get('stripe-signature')!

    let event
    try {
      event = stripe.webhooks.constructEvent(body, signature, webhookSecret)
    } catch (err) {
      console.error('Webhook signature verification failed:', err)
      return NextResponse.json({ error: 'Invalid signature' }, { status: 400 })
    }

    // Handle the event
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object
        const farmId = session.metadata?.farm_id

        if (farmId && session.subscription) {
          await supabaseAdmin
            .from('farms')
            .update({
              stripe_subscription_id: session.subscription as string,
              subscription_status: 'active'
            })
            .eq('id', farmId)
        }
        break
      }

      case 'customer.subscription.updated': {
        const subscription = event.data.object
        await supabaseAdmin
          .from('farms')
          .update({
            subscription_status: subscription.status
          })
          .eq('stripe_subscription_id', subscription.id)
        break
      }

      case 'customer.subscription.deleted': {
        const subscription = event.data.object
        await supabaseAdmin
          .from('farms')
          .update({
            subscription_status: 'canceled'
          })
          .eq('stripe_subscription_id', subscription.id)
        break
      }

      default:
        console.log(`Unhandled event type ${event.type}`)
    }

    return NextResponse.json({ received: true })
  } catch (error) {
    console.error('Error handling webhook:', error)
    Sentry.captureException(error)
    return NextResponse.json(
      { error: 'Webhook handler failed' },
      { status: 500 }
    )
  }
}
