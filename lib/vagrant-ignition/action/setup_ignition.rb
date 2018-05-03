require_relative 'vmdk_gen'

module VagrantPlugins
  module Ignition
    module Action
      class SetupIgnition
        def initialize(app, env)
          @app = app
        end

        def call(env)
          @env = env

          if env[:machine].config.ignition.enabled == false
            @app.call(env)
            return
          end

          config_path = env[:machine].config.ignition.path
          drive_name = env[:machine].config.ignition.drive_name
          drive_root = env[:machine].config.ignition.drive_root

          hostname = env[:machine].config.ignition.hostname
          internal_adapter = env[:machine].config.ignition.internal_adapter
          ip = env[:machine].config.ignition.ip

          controller = env[:machine].config.ignition.controller
          device = env[:machine].config.ignition.device
          port = env[:machine].config.ignition.port

          vmdk_gen(config_path, drive_name, drive_root, hostname, ip, internal_adapter, env)

          env[:machine].ui.info "Configuring Ignition Config Drive"
          env[:machine].provider.driver.execute("storageattach", "#{env[:machine].id}", "--storagectl", "#{controller}", "--device", "#{device}", "--port", "#{port}", "--type", "hdd", "--medium", "#{File.join(drive_root, (drive_name + ".vmdk"))}")

          # Continue through the middleware chain
          @app.call(env)
        end
      end
    end
  end
end
