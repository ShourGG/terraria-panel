// Linux系统信息接口
export interface SystemInfo {
  hostname: string;
  kernel: string;
  osType: string;
  osRelease: string;
  uptime: number;
  loadAvg: number[];
  arch: string;
  cpuModel: string;
  cpuCores: number;
  totalMemory: number;
  freeMemory: number;
}

// 系统资源使用情况接口
export interface SystemResources {
  cpu: {
    usage: number;
    temp: number;
  };
  memory: {
    total: number;
    used: number;
    free: number;
    buffers: number;
    cached: number;
    usagePercent: number;
  };
  swap: {
    total: number;
    used: number;
    free: number;
    usagePercent: number;
  };
  disk: {
    total: number;
    used: number;
    free: number;
    usagePercent: number;
  };
  network: {
    interfaces: NetworkInterface[];
  };
}

// 网络接口信息
export interface NetworkInterface {
  name: string;
  ip: string;
  mac: string;
  rxBytes: number;
  txBytes: number;
  rxPackets: number;
  txPackets: number;
}

// 进程信息接口
export interface Process {
  pid: number;
  ppid: number;
  uid: number;
  user: string;
  cmd: string;
  cpu: number;
  memory: number;
  state: string;
  startTime: string;
}

// 服务信息接口
export interface Service {
  name: string;
  status: 'active' | 'inactive' | 'failed';
  enabled: boolean;
  description: string;
}

// 文件系统信息接口
export interface FileSystemInfo {
  filesystems: FileSystem[];
}

// 文件系统详情
export interface FileSystem {
  filesystem: string;
  type: string;
  size: number;
  used: number;
  available: number;
  mountpoint: string;
  usagePercent: number;
}

// 目录内容项接口
export interface DirectoryItem {
  name: string;
  path: string;
  type: 'file' | 'directory' | 'symlink' | 'other';
  size: number;
  owner: string;
  group: string;
  permissions: string;
  modTime: string;
}

// 命令执行结果接口
export interface CommandResult {
  stdout: string;
  stderr: string;
  exitCode: number;
  executionTime: number;
}

// 命令历史记录接口
export interface CommandHistoryItem {
  id: number;
  command: string;
  exitCode: number;
  executedAt: string;
  executionTime: number;
}

// 系统用户接口
export interface SystemUser {
  username: string;
  uid: number;
  gid: number;
  home: string;
  shell: string;
  lastLogin?: string;
} 