module Capper
  module Utils
    module Bluepill

      def bluepill_config(name, body, options={})
        set(:bluepill_configs, fetch(:bluepill_configs, {}).merge(name => {
          :options => options, :body => body
        }))
      end

    end
  end
end
