Spree::OrdersHelper.module_eval do
  def del_rewards_adjustments
    ZinreloIntegration::Order.new.zrl_del_rewards_adjustments(@order)
  end

  def add_rewards_adjustment(reward_id,reward_amt, reward_points)
    ZinreloIntegration::Order.new.zrl_add_rewards_adjustment(@order, reward_id,reward_amt, reward_points)
  end

end
