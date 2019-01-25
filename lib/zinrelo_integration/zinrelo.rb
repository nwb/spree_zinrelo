class Zinrelo
  include ActionView::Helpers::OutputSafetyHelper
  #zinrelo: get user points balance
  def user_point_profile(user_email, store_code)

    # now get to ZenDesk
    require "net/https"
    require "uri"
    url= "https://api.zinrelo.com/v1/loyalty/users/"+user_email

    headers={
        'Content-Type' => 'application/json',
        'Content-Encoding' => 'gzip',
        'partner-id' => Spree::ZinreloConfiguration.account[store_code]["partner_id"],
        'api-key' => Spree::ZinreloConfiguration.account[store_code]["api_key"]}
    # headers["Content-Type"] = 'application/json' unless body.niuri
    begin
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 2
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = http.get(uri.request_uri,headers )
      if response.code=='200'
        user_point_profile=JSON.parse(response.body)
        return user_point_profile["data"]
      end
    rescue
    end
  end

  #zinrelo: get redemption options for a users
  def zrl_getUserRedemption(user_email, store_code)

    params_str="?is_still_valid=true&order_by=allowed_redeem_points&count=10&start_index=0&fetch_eligible_redemptions=true"

    # now get to zinrelo
    require "net/https"
    require "uri"
    url= "https://api.zinrelo.com/v1/loyalty/users/"+user_email+"/redemptions?is_still_valid=true&order_by=allowed_redeem_points&count=10&start_index=0&fetch_eligible_redemptions=true"

    headers={
        'Content-Type' => 'application/json',
        'Content-Encoding' => 'gzip',
        'partner-id' => Spree::ZinreloConfiguration.account[store_code]["partner_id"],
        'api-key' => Spree::ZinreloConfiguration.account[store_code]["api_key"]}
    # headers["Content-Type"] = 'application/json' unless body.niuri
    begin
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 2
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = http.get(uri.request_uri,headers )

      if response.code=='200'
        rewards=JSON.parse(response.body)
        return rewards
      end
    rescue
    end
  end
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

    header = {"Content-Type"=> "text/json", "partner-id"=>Spree::ZinreloConfiguration.account[order.store.code]["partner_id"], "api-key"=>Spree::ZinreloConfiguration.account[order.store.code]["api_key"]}
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

  #zinrelo: redeem points
  def zrl_redeem(order, reward_id,reward_amt)

    require "net/https"
    require "uri"

    uri = URI.parse("https://api.zinrelo.com/v1/loyalty/redeem")

    header = {"Content-Type"=> "text/json", "partner-id"=>Spree::ZinreloConfiguration.account[order.store.code]["partner_id"], "api-key"=>Spree::ZinreloConfiguration.account[order.store.code]["api_key"]}
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