Rails.configuration.stripe = {
  :publishable_key => ENV['PUBLISHABLE_KEY'],
  :secret_key      => ENV['SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

# Rails.configuration.stripe2 = {
#   :publishable_key => ENV['PUBLISHABLE_KEY_SLEDDING'],
#   :secret_key      => ENV['SECRET_KEY_SLEDDING']
# }

# Stripe.api_key2 = Rails.configuration.stripe2[:secret_key]
