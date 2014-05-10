module Docker
  module DefaultConfigs
    def default_creation_config
      {
        Hostname: '',
        User: '',
        Memory: 0,
        MemorySwap: 0,
        AttachStdin: false,
        AttachStdout: true,
        AttachStderr: true,
        PortSpecs: nil,
        Tty: false,
        OpenStdin: false,
        StdinOnce: false,
        Env: nil,
        Cmd: '',
        Image: '',
        Volumes: {},
        WorkingDir: '',
        NetworkDisabled: false,
        ExposedPorts: {}
      }
    end

    def default_start_config
      {
        Binds: [],
        LxcConf: {},
        PortBindings: {},
        PublishAllPorts: false,
        Privileged: false,
        Dns: ["8.8.8.8"],
        VolumesFrom: []
      }
    end
  end
end
