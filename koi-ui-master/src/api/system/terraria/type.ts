/**
 * 泰拉瑞亚服务器相关类型定义
 */

// 服务器状态信息
export interface TerrariaServerInfo {
  status: string; // 服务器状态：running, starting, stopping, stopped
  version: string; // 服务器版本
  worldName: string; // 世界名称
  players: TerrariaPlayer[]; // 在线玩家列表
  maxPlayers: number; // 最大玩家数
  uptime: number; // 运行时间（秒）
  port: number; // 服务器端口
  difficulty: string; // 难度
  memoryUsage: number; // 内存使用（字节）
  cpuUsage: number; // CPU使用率（百分比）
}

// 玩家信息
export interface TerrariaPlayer {
  id: number; // 玩家ID
  name: string; // 玩家名称
  ip: string; // IP地址
  joinTime: string; // 加入时间
  health: number; // 当前生命值
  maxHealth: number; // 最大生命值
  inventory?: any[]; // 物品栏（可选）
  position?: { x: number; y: number }; // 位置（可选）
}

// 物品信息
export interface TerrariaItem {
  id: number;
  name: string;
  stack: number;
  maxStack: number;
  prefix?: string;
}

// 世界信息
export interface TerrariaWorld {
  name: string;
  path: string;
  size: 'small' | 'medium' | 'large';
  difficulty: 'normal' | 'expert' | 'master' | 'journey';
  isSelected: boolean;
  lastModified: string;
  fileSizeBytes: number;
}

// 服务器配置
export interface TerrariaConfig {
  serverName: string;
  serverPort: number;
  maxPlayers: number;
  password: string;
  motd: string;
  worldFile: string;
  language: string;
  autoSave: boolean;
  autoSaveInterval: number;
  enableWhitelist: boolean;
  difficulty: 'normal' | 'expert' | 'master' | 'journey';
}

// 服务器日志条目
export interface TerrariaLogEntry {
  timestamp: string; // 时间戳
  level: string; // 日志级别：info, warn, error, debug
  message: string; // 日志消息
}

// 备份信息
export interface TerrariaBackup {
  id: string;
  timestamp: string;
  worldName: string;
  fileSizeBytes: number;
  note?: string;
}

// 封禁信息
export interface TerrariaBan {
  ip: string;
  name: string;
  reason: string;
  bannedOn: string;
  bannedBy: string;
  expiration?: string;
}

// 插件信息
export interface TerrariaPlugin {
  name: string;
  version: string;
  author: string;
  description: string;
  enabled: boolean;
  hasConfig: boolean;
}

// 系统信息接口
export interface SystemInfo {
  os: string; // 操作系统
  arch: string; // 系统架构
  cpuModel: string; // CPU型号
  cpuCores: number; // CPU核心数
  cpuUsage: number; // CPU使用率（百分比）
  totalMem: number; // 总内存（字节）
  freeMem: number; // 可用内存（字节）
  memUsage: number; // 内存使用率（百分比）
  totalDisk: number; // 总磁盘空间（字节）
  freeDisk: number; // 可用磁盘空间（字节）
  diskUsage: number; // 磁盘使用率（百分比）
}

// 房间信息接口
export interface RoomInfo {
  name: string; // 房间名称
  password: string; // 房间密码
  maxPlayers: number; // 最大玩家数
  isPublic: boolean; // 是否公开
  createdAt: string; // 创建时间
  description: string; // 房间描述
}

// 进程信息接口
export interface ProcessInfo {
  pid: number; // 进程ID
  name: string; // 进程名称
  cpu: number; // CPU使用率
  memory: number; // 内存使用（字节）
  uptime: number; // 运行时间（秒）
  command?: string; // 命令行（可选）
}

// 命令历史项接口
export interface CommandHistoryItem {
  type: string; // 命令类型：server, system
  command: string; // 命令内容
  output: string; // 命令输出
  timestamp: string; // 执行时间
}

// Boss信息接口
export interface BossInfo {
  id: string; // Boss ID
  name: string; // Boss 名称
}

// API响应接口
export interface ApiResponse<T> {
  code: number; // 状态码
  message: string; // 消息
  data: T; // 数据
} 