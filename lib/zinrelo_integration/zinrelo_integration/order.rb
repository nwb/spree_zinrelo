module ZinreloIntegration
  class Order
    def zrl_add_rewards_adjustment(order, reward_id,reward_amt, reward_points)
      zrl_del_rewards_adjustments(order)
      #if not, add adjustment
      adj=order.adjustments.new()
      adj.amount= -reward_amt.to_f
      adj.label="Points Redemption " +  reward_id + " " + reward_points
      adj.order_id= order.id
      adj.save!
    end

    def zrl_del_rewards_adjustments(order)
      existing_reward_adjs= order.adjustments
      existing_reward_adjs.each do |adjustment|
        if adjustment.label.slice(0..17) == 'Points Redemption '
          adjustment.delete
        end
      end
    end

  end
end