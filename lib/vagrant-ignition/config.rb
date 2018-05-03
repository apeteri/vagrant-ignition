module VagrantPlugins
  module Ignition
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :enabled
      attr_accessor :path
      attr_accessor :config_obj
      attr_accessor :drive_name
      attr_accessor :drive_root
      attr_accessor :hostname
      # Device name and IP address for the internal network's NIC
      attr_accessor :internal_adapter
      attr_accessor :ip
      # Attributes controlling where to attach the config drive
      attr_accessor :controller
      attr_accessor :device
      attr_accessor :port

      def initialize
        @enabled          = UNSET_VALUE
        @path             = UNSET_VALUE
        @config_obj       = UNSET_VALUE
        @drive_name       = UNSET_VALUE
        @drive_root       = UNSET_VALUE
        @hostname         = UNSET_VALUE
        @internal_adapter = UNSET_VALUE
        @ip               = UNSET_VALUE
        @controller       = UNSET_VALUE
        @device           = UNSET_VALUE
        @port             = UNSET_VALUE
      end

      def finalize!
        @enabled          = false            if @enabled          == UNSET_VALUE
        @path             = nil              if @path             == UNSET_VALUE
        @drive_name       = "config"         if @drive_name       == UNSET_VALUE
        @drive_root       = "./"             if @drive_root       == UNSET_VALUE
        @hostname         = nil              if @hostname         == UNSET_VALUE
        @internal_adapter = "eth1"           if @internal_adapter == UNSET_VALUE
        @ip               = nil              if @ip               == UNSET_VALUE
        @controller       = "IDE Controller" if @controller       == UNSET_VALUE
        @device           = 0                if @device           == UNSET_VALUE
        @port             = 1                if @port             == UNSET_VALUE
      end
    end
  end
end
