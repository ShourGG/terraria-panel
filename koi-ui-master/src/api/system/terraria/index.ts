import request from '@/utils/request';
import type { AxiosPromise } from 'axios';
import type {
  TerrariaServerInfo,
  TerrariaLogEntry,
  SystemInfo,
  RoomInfo,
  ProcessInfo
} from './type';

/**
 * 泰拉瑞亚服务器管理API接口
 */

// 获取服务器状态
export function getServerStatus(): AxiosPromise<TerrariaServerInfo> {
  return request({
    url: '/terraria/status',
    method: 'get'
  });
}

// 启动服务器
export function startServer(params?: any): AxiosPromise<any> {
  return request({
    url: '/terraria/start',
    method: 'post',
    data: params
  });
}

// 停止服务器
export function stopServer(): AxiosPromise<any> {
  return request({
    url: '/terraria/stop',
    method: 'post'
  });
}

// 重启服务器
export function restartServer(): AxiosPromise<any> {
  return request({
    url: '/terraria/restart',
    method: 'post'
  });
}

// 获取服务器配置
export function getServerConfig() {
  // This function is not provided in the new implementation
  throw new Error("getServerConfig function is not implemented in the new implementation");
}

// 更新服务器配置
export function updateServerConfig(config: any) {
  // This function is not provided in the new implementation
  throw new Error("updateServerConfig function is not implemented in the new implementation");
}

// 获取世界列表
export function getWorldList() {
  // This function is not provided in the new implementation
  throw new Error("getWorldList function is not implemented in the new implementation");
}

// 创建新世界
export function createWorld(params: {
  name: string;
  size: 'small' | 'medium' | 'large';
  difficulty: 'normal' | 'expert' | 'master' | 'journey';
  seed?: string;
}) {
  // This function is not provided in the new implementation
  throw new Error("createWorld function is not implemented in the new implementation");
}

// 选择世界
export function selectWorld(path: string) {
  // This function is not provided in the new implementation
  throw new Error("selectWorld function is not implemented in the new implementation");
}

// 删除世界
export function deleteWorld(path: string) {
  // This function is not provided in the new implementation
  throw new Error("deleteWorld function is not implemented in the new implementation");
}

// 获取玩家列表
export function getPlayerList() {
  // This function is not provided in the new implementation
  throw new Error("getPlayerList function is not implemented in the new implementation");
}

// 踢出玩家
export function kickPlayer(playerId: number): AxiosPromise<any> {
  return request({
    url: '/terraria/player/kick',
    method: 'post',
    data: { playerId }
  });
}

// 封禁玩家
export function banPlayer(playerId: number): AxiosPromise<any> {
  return request({
    url: '/terraria/player/ban',
    method: 'post',
    data: { playerId }
  });
}

// 获取封禁列表
export function getBanList() {
  // This function is not provided in the new implementation
  throw new Error("getBanList function is not implemented in the new implementation");
}

// 解除封禁
export function unbanPlayer(ip: string) {
  // This function is not provided in the new implementation
  throw new Error("unbanPlayer function is not implemented in the new implementation");
}

// 发送服务器消息
export function sendServerMessage(message: string): AxiosPromise<any> {
  return request({
    url: '/terraria/message',
    method: 'post',
    data: { message }
  });
}

// 执行服务器命令
export function executeServerCommand(command: string): AxiosPromise<any> {
  return request({
    url: '/terraria/command',
    method: 'post',
    data: { command }
  });
}

// 获取服务器日志
export function getServerLogs(limit?: number): AxiosPromise<TerrariaLogEntry[]> {
  return request({
    url: '/terraria/logs',
    method: 'get',
    params: { limit }
  });
}

// 创建世界备份
export function createBackup(): AxiosPromise<any> {
  return request({
    url: '/terraria/backup',
    method: 'post'
  });
}

// 获取备份列表
export function getBackupList() {
  // This function is not provided in the new implementation
  throw new Error("getBackupList function is not implemented in the new implementation");
}

// 恢复备份
export function restoreBackup(id: string) {
  // This function is not provided in the new implementation
  throw new Error("restoreBackup function is not implemented in the new implementation");
}

// 删除备份
export function deleteBackup(id: string) {
  // This function is not provided in the new implementation
  throw new Error("deleteBackup function is not implemented in the new implementation");
}

// 获取插件列表
export function getPluginList() {
  // This function is not provided in the new implementation
  throw new Error("getPluginList function is not implemented in the new implementation");
}

// 启用/禁用插件
export function togglePlugin(name: string, enabled: boolean) {
  // This function is not provided in the new implementation
  throw new Error("togglePlugin function is not implemented in the new implementation");
}

// 获取插件配置
export function getPluginConfig(name: string) {
  // This function is not provided in the new implementation
  throw new Error("getPluginConfig function is not implemented in the new implementation");
}

// 更新插件配置
export function updatePluginConfig(name: string, config: any) {
  // This function is not provided in the new implementation
  throw new Error("updatePluginConfig function is not implemented in the new implementation");
}

// 上传TShock服务器文件
export function uploadTShockFile(formData: FormData): AxiosPromise<any> {
  return request({
    url: '/terraria/upload/tshock',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  });
}

// 获取系统信息
export function getSystemInformation(): AxiosPromise<SystemInfo> {
  return request({
    url: '/system/info',
    method: 'get'
  });
}

// 获取房间信息
export function getRoomInformation(): AxiosPromise<RoomInfo> {
  return request({
    url: '/terraria/room',
    method: 'get'
  });
}

// 更新房间信息
export function updateRoomInformation(roomInfo: RoomInfo): AxiosPromise<any> {
  return request({
    url: '/terraria/room',
    method: 'post',
    data: roomInfo
  });
}

// 执行系统命令
export function executeSystemCommand(command: string): AxiosPromise<any> {
  return request({
    url: '/system/command',
    method: 'post',
    data: { command }
  });
}

// 获取进程列表
export function getProcessList(): AxiosPromise<ProcessInfo[]> {
  return request({
    url: '/system/processes',
    method: 'get'
  });
}

// 终止进程
export function killGameProcess(pid: number): AxiosPromise<any> {
  return request({
    url: '/system/process/kill',
    method: 'post',
    data: { pid }
  });
}

// 设置白天
export function setDayTime(): AxiosPromise<any> {
  return request({
    url: '/terraria/world/daytime',
    method: 'post',
    data: { value: true }
  });
}

// 设置黑夜
export function setNightTime(): AxiosPromise<any> {
  return request({
    url: '/terraria/world/daytime',
    method: 'post',
    data: { value: false }
  });
}

// 切换雨天
export function toggleRain(value: boolean): AxiosPromise<any> {
  return request({
    url: '/terraria/world/rain',
    method: 'post',
    data: { value }
  });
}

// 切换PvP
export function togglePvP(value: boolean): AxiosPromise<any> {
  return request({
    url: '/terraria/world/pvp',
    method: 'post',
    data: { value }
  });
}

// 保存世界
export function saveWorldNow(): AxiosPromise<any> {
  return request({
    url: '/terraria/world/save',
    method: 'post'
  });
}

// 召唤Boss
export function spawnBoss(bossId: string): AxiosPromise<any> {
  return request({
    url: '/terraria/world/spawn-boss',
    method: 'post',
    data: { bossId }
  });
} 