Spree::OrdersHelper.module_eval do

  #zinrelo: get user points balance
  def user_point_profile(user_email)

    # now get to ZenDesk
    require "net/https"
    require "uri"
    url= "https://api.zinrelo.com/v1/loyalty/users/"+user_email

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

      response = http.get(uri.request_uri,headers )
      if response.code=='200'
        user_point_profile=JSON.parse(response.body)
        return user_point_profile["data"]
      end
    rescue
    end
  end

  #zinrelo: get redemption options for a users
  def zrl_getUserRedemption(user_email)

    params_str="?is_still_valid=true&order_by=allowed_redeem_points&count=10&start_index=0&fetch_eligible_redemptions=true"

    # now get to zinrelo
    require "net/https"
    require "uri"
    url= "https://api.zinrelo.com/v1/loyalty/users/"+@order.email+"/redemptions?is_still_valid=true&order_by=allowed_redeem_points&count=10&start_index=0&fetch_eligible_redemptions=true"

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

      response = http.get(uri.request_uri,headers )

      if response.code=='200'
        rewards=JSON.parse(response.body)
        return rewards
      end
    rescue
    end
  end

end
