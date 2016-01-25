def convert_to_bgn(price, currency)
  price *= 1.7408 if currency == :usd
  price *= 1.9557 if currency == :eur
  price *= 2.6415 if currency == :gbp
  price.round(2)
end

def compare_prices(price_one, currency_one, price_two, currency_two)
  result = convert_to_bgn(price_one, currency_one)
  result -= convert_to_bgn(price_two, currency_two)
end
