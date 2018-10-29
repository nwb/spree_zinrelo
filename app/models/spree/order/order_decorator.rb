module Spree
  Order.class_eval do

    def rewards_redeemed
      existing_reward_adjs =  self.adjustments
      if existing_reward_adjs.length >0
        existing_reward_adjs.each do |adjustment|
          if adjustment.label.slice(0..17) == 'Points Redemption '
            return adjustment
          end
        end
      end
    end

  end
end
