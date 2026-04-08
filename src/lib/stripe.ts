import Stripe from 'stripe'

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
  typescript: true,
})

/**
 * Creates a Stripe customer and product for a new user on first login
 */
export async function createStripeCustomerAndProduct(userId: string, email: string) {
  try {
    // Create Stripe customer
    const customer = await stripe.customers.create({
      email,
      metadata: {
        supabase_user_id: userId,
      },
    })

    // Create a product for drone crop monitoring
    const product = await stripe.products.create({
      name: 'Drone Crop Swarm - Pro Plan',
      description: 'Advanced drone swarm management and crop monitoring',
      metadata: {
        supabase_user_id: userId,
      },
    })

    // Create a price for the product
    const price = await stripe.prices.create({
      product: product.id,
      unit_amount: 9900, // $99.00 per month
      currency: 'usd',
      recurring: {
        interval: 'month',
      },
    })

    return {
      customerId: customer.id,
      productId: product.id,
      priceId: price.id,
    }
  } catch (error) {
    console.error('Error creating Stripe customer and product:', error)
    throw error
  }
}

/**
 * Creates a checkout session for a user to subscribe
 */
export async function createCheckoutSession(
  customerId: string,
  priceId: string,
  farmId: string
) {
  const session = await stripe.checkout.sessions.create({
    customer: customerId,
    line_items: [
      {
        price: priceId,
        quantity: 1,
      },
    ],
    mode: 'subscription',
    success_url: `${process.env.NEXT_PUBLIC_URL}/dashboard?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.NEXT_PUBLIC_URL}/dashboard`,
    metadata: {
      farm_id: farmId,
    },
  })

  return session
}
