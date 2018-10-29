Spree::CheckoutController.class_eval do

  #Zinrelo: post purchase transactions
  def zrl_purchase(order)

    #this is to post purchase transaction to zinerl
    request={}
    data={}
    products=[]

    data={}
    data["user_email"]= order.email
    data["total"]=order.total.to_s
    data["subtotal"]=order.item_total.to_s
    data["order_id"]=order.id
    data["currency"]=order.currency
    data["coupon_code"]

    product={}
    product["product_id"]= order.line_items.first.variant_id.to_s
    product["price"]=order.line_items.first.price.to_s
    product["quantity"]=order.line_items.first.quantity.to_s
    product["title"]=order.line_items.first.name
    product["url"] = "https://#{order.store.url}/products/" + order.line_items.first.product.slug + "?variant_id=" + order.line_items.first.variant.id.to_s
    product["img_url"]
    product["category"]
    product["tags"]

    products << product

    data["products"]=products

#    request["data"]=data

    params={'user_email'=>order.email,
            'total' => order.total.to_s,
            'subtotal' => order.item_total.to_s,
            'order_id' => order.id,
            'currency' => order.currency,
            'coupon_code' => ''}


    params_str="?user_email="+order.email+"&total="+order.total.to_s+"&subtotal="+order.item_total.to_s+"&order_id="+order.number.to_s+"&currency="+order.currency

# now post to ZenDesk
    require "net/https"
    require "uri"
    url= "https://api.zinrelo.com/v1/loyalty/purchase"+params_str

    Rails.logger.error("data object to be posed:\n #{request.to_json}")
    body= request.to_json
    headers={
        'Content-Type' => 'application/json',
        'Content-Encoding' => 'gzip',
        'partner-id' => Spree::ZinreloConfiguration.account[@order.store.code]["partner_id"],
        'api-key' => Spree::ZinreloConfiguration.account[@order.store.code]["api_key"]}
# headers["Content-Type"] = 'application/json' unless body.niuri
    begin
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 2
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = http.post(uri.request_uri,body, headers )
      #request.body=body

      #     response = http.request(request)

      Rails.logger.error("post to Zinrelo response:\n #{response.body.to_yaml}")

      result=JSON.parse(response.body)

      Rails.logger.error("Zinrelo request is created.\nthe post body is: \n" + request.to_json)
    rescue

      Rails.logger.error("Zinrelo request post failed\n the post body is: \n" + request.to_json)
    end
  end

  def add_rewards_adjustment(order, reward_id,reward_amt, reward_points)
    del_rewards_adjustments(order)
    #if not, add adjustment
    adj=order.adjustments.new()
    adj.amount= -reward_amt.to_f
    adj.label="Points Redemption " +  reward_id + " " + reward_points
    adj.order_id= order.id
    adj.save!
  end

  def del_rewards_adjustments(order)
    existing_reward_adjs= order.adjustments
    existing_reward_adjs.each do |adjustment|
      if adjustment.label.slice(0..17) == 'Points Redemption '
        adjustment.delete
      end
    end
  end

  #zinrelo: redeem points
  def zrl_redeem(order, reward_id,reward_amt)
    #POST https://api.zinrelo.com/v1/loyalty/redeem

    params_str="?user_email="+order.email+"&redemption_id="+reward_id

    require "net/https"
    require "uri"
    url= "https://api.zinrelo.com/v1/loyalty/redeem"+params_str

    Rails.logger.error("Zinrelo Points redeem:\n #{params_str}")
    headers={
        'Content-Type' => 'application/json',
        'Content-Encoding' => 'gzip',
        'partner-id' => Spree::ZinreloConfiguration.account[@order.store.code]["partner_id"],
        'api-key' => Spree::ZinreloConfiguration.account[@order.store.code]["api_key"]}

    begin
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 2
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = http.post(uri.request_uri,"", headers )

      Rails.logger.error("post to Zinrelo response:\n #{response.body.to_yaml}")

      result=JSON.parse(response.body)

      Rails.logger.error("Zinrelo point redemption\nthe post body is: \n" + params_str)
    rescue

      Rails.logger.error("Zinrelo point redemption\n the post body is: \n" + params_str)
    end
  end

end