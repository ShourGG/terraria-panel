import axios from "@/utils/axios";

/**
 * Linux系统管理API接口
 */

// 获取系统信息
export const getSystemInfo = () => {
  return axios({
    url: "/api/linux/system/info",
    method: "get"
  });
};

// 获取系统资源使用情况
export const getSystemResources = () => {
  return axios({
    url: "/api/linux/system/resources",
    method: "get"
  });
};

// 获取系统进程列表
export const getProcessList = (params: any) => {
  return axios({
    url: "/api/linux/system/processes",
    method: "get",
    params
  });
};

// 结束进程
export const killProcess = (pid: number) => {
  return axios({
    url: `/api/linux/system/process/${pid}`,
    method: "delete"
  });
};

// 获取服务列表
export const getServiceList = () => {
  return axios({
    url: "/api/linux/services",
    method: "get"
  });
};

// 控制服务状态（启动/停止/重启）
export const controlService = (name: string, action: 'start' | 'stop' | 'restart') => {
  return axios({
    url: `/api/linux/service/${name}/${action}`,
    method: "post"
  });
};

// 获取文件系统信息
export const getFileSystemInfo = () => {
  return axios({
    url: "/api/linux/fs/info",
    method: "get"
  });
};

// 获取目录内容
export const getDirectoryContents = (path: string) => {
  return axios({
    url: "/api/linux/fs/list",
    method: "get",
    params: { path }
  });
};

// 创建文件/目录
export const createFileOrDir = (path: string, type: 'file' | 'directory', content?: string) => {
  return axios({
    url: "/api/linux/fs/create",
    method: "post",
    data: { path, type, content }
  });
};

// 删除文件/目录
export const deleteFileOrDir = (path: string, recursive: boolean = false) => {
  return axios({
    url: "/api/linux/fs/delete",
    method: "delete",
    data: { path, recursive }
  });
};

// 读取文件内容
export const readFile = (path: string) => {
  return axios({
    url: "/api/linux/fs/read",
    method: "get",
    params: { path }
  });
};

// 写入文件内容
export const writeFile = (path: string, content: string) => {
  return axios({
    url: "/api/linux/fs/write",
    method: "post",
    data: { path, content }
  });
};

// 执行命令
export const executeCommand = (command: string) => {
  return axios({
    url: "/api/linux/command/execute",
    method: "post",
    data: { command }
  });
};

// 获取命令执行历史
export const getCommandHistory = () => {
  return axios({
    url: "/api/linux/command/history",
    method: "get"
  });
};

// 获取系统用户列表
export const getSystemUsers = () => {
  return axios({
    url: "/api/linux/users",
    method: "get"
  });
};

// 创建系统用户
export const createSystemUser = (username: string, password: string) => {
  return axios({
    url: "/api/linux/user/create",
    method: "post",
    data: { username, password }
  });
};

// 删除系统用户
export const deleteSystemUser = (username: string) => {
  return axios({
    url: "/api/linux/user/delete",
    method: "delete",
    data: { username }
  });
}; 