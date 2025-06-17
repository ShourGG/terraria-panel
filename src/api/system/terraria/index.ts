import axios from "@/utils/axios";
import type { TerrariaConfig } from "./type";

/**
 * 泰拉瑞亚服务器管理API接口
 */

// 获取服务器状态
export const getServerStatus = () => {
  return axios({
    url: "/api/terraria/status",
    method: "get"
  });
};

// 启动服务器
export const startServer = () => {
  return axios({
    url: "/api/terraria/control/start",
    method: "post"
  });
};

// 停止服务器
export const stopServer = () => {
  return axios({
    url: "/api/terraria/control/stop",
    method: "post"
  });
};

// 重启服务器
export const restartServer = () => {
  return axios({
    url: "/api/terraria/control/restart",
    method: "post"
  });
};

// 获取服务器配置
export const getServerConfig = () => {
  return axios({
    url: "/api/terraria/config",
    method: "get"
  });
};

// 更新服务器配置
export const updateServerConfig = (config: TerrariaConfig) => {
  return axios({
    url: "/api/terraria/config",
    method: "put",
    data: config
  });
};

// 获取世界列表
export const getWorldList = () => {
  return axios({
    url: "/api/terraria/worlds",
    method: "get"
  });
};

// 创建新世界
export const createWorld = (params: {
  name: string;
  size: 'small' | 'medium' | 'large';
  difficulty: 'normal' | 'expert' | 'master' | 'journey';
  seed?: string;
}) => {
  return axios({
    url: "/api/terraria/worlds/create",
    method: "post",
    data: params
  });
};

// 选择世界
export const selectWorld = (path: string) => {
  return axios({
    url: "/api/terraria/worlds/select",
    method: "post",
    data: { path }
  });
};

// 删除世界
export const deleteWorld = (path: string) => {
  return axios({
    url: "/api/terraria/worlds/delete",
    method: "delete",
    data: { path }
  });
};

// 获取玩家列表
export const getPlayerList = () => {
  return axios({
    url: "/api/terraria/players",
    method: "get"
  });
};

// 踢出玩家
export const kickPlayer = (id: number) => {
  return axios({
    url: `/api/terraria/players/${id}/kick`,
    method: "post"
  });
};

// 封禁玩家
export const banPlayer = (id: number) => {
  return axios({
    url: `/api/terraria/players/${id}/ban`,
    method: "post"
  });
};

// 获取封禁列表
export const getBanList = () => {
  return axios({
    url: "/api/terraria/bans",
    method: "get"
  });
};

// 解除封禁
export const unbanPlayer = (ip: string) => {
  return axios({
    url: `/api/terraria/bans/${ip}`,
    method: "delete"
  });
};

// 发送服务器消息
export const sendServerMessage = (message: string) => {
  return axios({
    url: "/api/terraria/message",
    method: "post",
    data: { message }
  });
};

// 执行服务器命令
export const executeServerCommand = (command: string) => {
  return axios({
    url: "/api/terraria/command",
    method: "post",
    data: { command }
  });
};

// 获取服务器日志
export const getServerLogs = (lines: number = 100) => {
  return axios({
    url: "/api/terraria/logs",
    method: "get",
    params: { lines }
  });
};

// 创建世界备份
export const createBackup = (note?: string) => {
  return axios({
    url: "/api/terraria/backup/create",
    method: "post",
    data: { note }
  });
};

// 获取备份列表
export const getBackupList = () => {
  return axios({
    url: "/api/terraria/backups",
    method: "get"
  });
};

// 恢复备份
export const restoreBackup = (id: string) => {
  return axios({
    url: `/api/terraria/backup/${id}/restore`,
    method: "post"
  });
};

// 删除备份
export const deleteBackup = (id: string) => {
  return axios({
    url: `/api/terraria/backup/${id}`,
    method: "delete"
  });
};

// 获取插件列表
export const getPluginList = () => {
  return axios({
    url: "/api/terraria/plugins",
    method: "get"
  });
};

// 启用/禁用插件
export const togglePlugin = (name: string, enabled: boolean) => {
  return axios({
    url: `/api/terraria/plugins/${name}/toggle`,
    method: "post",
    data: { enabled }
  });
};

// 获取插件配置
export const getPluginConfig = (name: string) => {
  return axios({
    url: `/api/terraria/plugins/${name}/config`,
    method: "get"
  });
};

// 更新插件配置
export const updatePluginConfig = (name: string, config: any) => {
  return axios({
    url: `/api/terraria/plugins/${name}/config`,
    method: "put",
    data: { config }
  });
}; 