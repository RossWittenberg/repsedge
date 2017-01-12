if Rails.env.production?
    Rails.configuration.stripe = {
      :publishable_key => ENV['STIRPE_PUBLISHABLE_KEY'],
      :secret_key      => ENV['STIRPE_SECRET_KEY']
    }

    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    STRIPE_PUBLIC_KEY = ENV['STIRPE_PUBLISHABLE_KEY']
elsif Rails.env.development?
    Rails.configuration.stripe = {
      :publishable_key => ENV['STIRPE_TEST_PUBLISHABLE_KEY'],
      :secret_key      => ENV['STIRPE_TEST_SECRET_KEY']
    }

    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    STRIPE_PUBLIC_KEY = ENV['STIRPE_TEST_PUBLISHABLE_KEY']
end