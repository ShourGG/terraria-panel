// 泰拉瑞亚服务器信息接口
export interface TerrariaServerInfo {
  status: 'running' | 'stopped' | 'starting' | 'error';
  version: string;
  worldName: string;
  players: TerrariaPlayer[];
  maxPlayers: number;
  uptime: number;
  port: number;
  seed?: string;
  difficulty: string;
  memoryUsage: number;
  cpuUsage: number;
}

// 泰拉瑞亚玩家信息
export interface TerrariaPlayer {
  id: number;
  name: string;
  ip: string;
  joinTime: string;
  playTime: number;
  position: {
    x: number;
    y: number;
  };
  health: number;
  maxHealth: number;
  team?: string;
}

// 泰拉瑞亚世界信息
export interface TerrariaWorld {
  name: string;
  path: string;
  size: number;
  lastModified: string;
  difficulty: string;
  playTime: number;
  creationTime: string;
  seed?: string;
  isHardMode: boolean;
}

// 泰拉瑞亚服务器配置
export interface TerrariaConfig {
  port: number;
  maxPlayers: number;
  password?: string;
  motd?: string;
  worldPath: string;
  difficulty: 'normal' | 'expert' | 'master' | 'journey';
  autoCreate: boolean;
  seed?: string;
  banList: string[];
  autoSave: boolean;
  autoSaveInterval: number;
  language: string;
  secure: boolean;
  npcStream: number;
}

// 泰拉瑞亚命令响应
export interface TerrariaCommandResponse {
  success: boolean;
  message: string;
  timestamp: string;
}

// 泰拉瑞亚日志条目
export interface TerrariaLogEntry {
  timestamp: string;
  level: 'info' | 'warning' | 'error';
  message: string;
}

// 泰拉瑞亚备份信息
export interface TerrariaBackup {
  id: string;
  worldName: string;
  createdAt: string;
  size: number;
  path: string;
  note?: string;
}

// 泰拉瑞亚插件信息
export interface TerrariaPlugin {
  name: string;
  version: string;
  author: string;
  description: string;
  isEnabled: boolean;
  configPath?: string;
} 