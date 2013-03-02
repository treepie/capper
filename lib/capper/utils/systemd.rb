require "erubis"

module Capper
  module Utils
    module Systemd

      def systemctl(*args)
        run("systemctl --user " + [args].flatten.map(&:to_s).join(" "))
      end

    end
  end
end
