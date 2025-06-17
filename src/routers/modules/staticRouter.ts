import { RouteRecordRaw } from "vue-router";
import { HOME_URL, LOGIN_URL } from "@/config";
import Layout from "@/layouts/index.vue";

/**
 * Linux管理路由
 */
export const linuxRouter: RouteRecordRaw = {
  path: "/linux", // 路由访问路径[唯一]
  name: "linux", // 命名路由[唯一]
  component: Layout, // 一级路由，可以将子路由放置Main模块中
  redirect: "/linux/index", // 重定向路径
  meta: {
    title: "Linux管理", // 标题
    icon: "Monitor", // 图标
    isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
    isLink: "", // 是否外链[有值则是外链]
    isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
    isFull: "1", // 是否缓存全屏[0是，1否]
    isAffix: "1" // 是否缓存固定路由[0是，1否]
  },
  children: [
    {
      path: "/linux/index", // [唯一]
      name: "LinuxManagement",
      component: () => import("@/views/linux/index.vue"),
      meta: {
        title: "系统概览", // 标题
        icon: "Monitor", // 图标
        isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
        isLink: "", // 是否外链[有值则是外链]
        isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
        isFull: "1", // 是否缓存全屏[0是，1否]
        isAffix: "1" // 是否缓存固定路由[0是，1否]
      }
    },
    {
      path: "/linux/processes", // [唯一]
      name: "LinuxProcesses",
      component: () => import("@/views/linux/processes.vue"),
      meta: {
        title: "进程管理", // 标题
        icon: "List", // 图标
        isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
        isLink: "", // 是否外链[有值则是外链]
        isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
        isFull: "1", // 是否缓存全屏[0是，1否]
        isAffix: "1" // 是否缓存固定路由[0是，1否]
      }
    },
    {
      path: "/linux/services", // [唯一]
      name: "LinuxServices",
      component: () => import("@/views/linux/services.vue"),
      meta: {
        title: "服务管理", // 标题
        icon: "SetUp", // 图标
        isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
        isLink: "", // 是否外链[有值则是外链]
        isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
        isFull: "1", // 是否缓存全屏[0是，1否]
        isAffix: "1" // 是否缓存固定路由[0是，1否]
      }
    }
  ]
};

// 泰拉瑞亚管理路由
export const terrariaRouter = {
  path: "/terraria",
  component: () => import("@/layouts/index.vue"),
  redirect: "/terraria/index",
  meta: {
    icon: "Monitor",
    title: "泰拉瑞亚管理",
    rank: 2
  },
  children: [
    {
      path: "/terraria/index",
      name: "TerrariaIndex",
      component: () => import("@/views/terraria/index.vue"),
      meta: {
        icon: "HomeFilled",
        title: "服务器概览",
        showLink: true
      }
    },
    {
      path: "/terraria/worlds",
      name: "TerrariaWorlds",
      component: () => import("@/views/terraria/worlds.vue"),
      meta: {
        icon: "Planet",
        title: "世界管理",
        showLink: true
      }
    },
    {
      path: "/terraria/players",
      name: "TerrariaPlayers",
      component: () => import("@/views/terraria/players.vue"),
      meta: {
        icon: "User",
        title: "玩家管理",
        showLink: true
      }
    },
    {
      path: "/terraria/config",
      name: "TerrariaConfig",
      component: () => import("@/views/terraria/config.vue"),
      meta: {
        icon: "Setting",
        title: "服务器配置",
        showLink: true
      }
    },
    {
      path: "/terraria/backups",
      name: "TerrariaBackups",
      component: () => import("@/views/terraria/backups.vue"),
      meta: {
        icon: "Files",
        title: "备份管理",
        showLink: true
      }
    },
    {
      path: "/terraria/plugins",
      name: "TerrariaPlugins",
      component: () => import("@/views/terraria/plugins.vue"),
      meta: {
        icon: "Connection",
        title: "插件管理",
        showLink: true
      }
    },
    {
      path: "/terraria/logs",
      name: "TerrariaLogs",
      component: () => import("@/views/terraria/logs.vue"),
      meta: {
        icon: "List",
        title: "服务器日志",
        showLink: true
      }
    },
    {
      path: "/terraria/console",
      name: "TerrariaConsole",
      component: () => import("@/views/terraria/console.vue"),
      meta: {
        icon: "Terminal",
        title: "服务器控制台",
        showLink: true
      }
    }
  ]
};

/**
 * 静态路由
 */
export const staticRouter: RouteRecordRaw[] = [
  /** 首页 */
  {
    path: "/home/index", // [唯一]
    component: () => import("@/views/home/index.vue"),
    meta: {
      title: "首页", // 标题
      icon: "HomeFilled", // 图标 HomeFilled
      isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
      isLink: "", // 是否外链[有值则是外链]
      isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
      isFull: "1", // 是否缓存全屏[0是，1否]
      isAffix: "0" // 是否缓存固定路由[0是，1否]
    }
  },
  // Linux管理路由
  linuxRouter,
  terrariaRouter
]; 