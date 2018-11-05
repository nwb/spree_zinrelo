
Spree::CheckoutController.class_eval do
  include ActionView::Helpers::OutputSafetyHelper

  #Zinrelo: post purchase transactions
  def zrl_purchase(order)

    #this is to post purchase transaction to zinerl
    request={}
    products_param=[]

    order.line_items.each do |product|
      product_param={:product_id => product.variant_id.to_s,:price => product.price.to_s, :quantity=> product.quantity.to_s, :title => product.name, :url =>"https://#{order.store.url}/products/" + product.product.slug + "?variant_id=" + product.variant.id.to_s, :img_url =>product.variant.images.first.attachment.url(:original),:category => ''}
      products_param << product_param
    end

    require "net/https"
    require "uri"

    uri = URI.parse("https://api.zinrelo.com/v1/loyalty/purchase")

    header = {"Content-Type"=> "text/json", "partner-id"=>Spree::ZinreloConfiguration.account[@order.store.code]["partner_id"], "api-key"=>Spree::ZinreloConfiguration.account[@order.store.code]["api_key"]}
    params = { :user_email => order.email, :order_id => order.number.to_s, :total =>order.total.to_s, :subtotal => order.item_total.to_s,:currency =>order.currency,:products => raw(products_param.to_json) }

  begin
    uri.query = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 2
    http.use_ssl = (uri.scheme == "https")
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri, header)
    response = http.request(request)

      Rails.logger.error("post to Zinrelo response:\n #{response.body.to_yaml}")

      result=JSON.parse(response.body)

      Rails.logger.error("Zinrelo request is created.\nthe post body is: \n" + uri.inspect)
    rescue

      Rails.logger.error("Zinrelo request post failed\n the post body is: \n" + uri.inspect)
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

    require "net/https"
    require "uri"

    uri = URI.parse("https://api.zinrelo.com/v1/loyalty/redeem")

    header = {"Content-Type"=> "text/json", "partner-id"=>Spree::ZinreloConfiguration.account[@order.store.code]["partner_id"], "api-key"=>Spree::ZinreloConfiguration.account[@order.store.code]["api_key"]}
    params = { :user_email => order.email, :redemption_id => reward_id}

    begin
      uri.query = URI.encode_www_form(params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 2
      http.use_ssl = (uri.scheme == "https")
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri, header)
      response = http.request(request)

      Rails.logger.error("post to Zinrelo response:\n #{response.body.to_yaml}")

      result=JSON.parse(response.body)

      Rails.logger.error("Zinrelo point redemption\nthe post body is: \n" + uri.inspect)
    rescue

      Rails.logger.error("Zinrelo point redemption\n the post body is: \n" + uri.inspect)
    end
  end

end