import { RouteRecordRaw } from "vue-router";
import Layout from "@/layouts/index.vue";

// 设置首页为泰拉瑞亚管理页面
const HOME_URL = "/terraria/overview";
const LOGIN_URL = "/login";

/**
 * LayoutRouter (布局路由)
 */
export const layoutRouter: RouteRecordRaw[] = [
  {
    // 登录成功以后展示数据的路由[一级路由，可以将子路由放置Main模块中(核心)]
    path: "/", // 路由访问路径[唯一]
    name: "layout", // 命名路由[唯一]
    component: Layout, // 登录进入这个页面，这个页面是整个布局
    redirect: HOME_URL, // 重定向到泰拉瑞亚管理页面
    children: []
  },
  {
    path: LOGIN_URL,
    name: "login",
    component: () => import("@/views/login/index.vue"),
    meta: {
      title: "登录"
    }
  }
];

/**
 * LayoutRouter (布局路由)
 */
export const staticRouter: RouteRecordRaw[] = [
  // 泰拉瑞亚服务器管理 - 作为唯一的主模块
  {
    path: "/terraria", // 路由访问路径[唯一]
    name: "terraria", // 命名路由[唯一]
    component: Layout, // 一级路由，可以将子路由放置Main模块中
    meta: {
      title: "泰拉瑞亚管理", // 标题
      icon: "Monitor", // 图标
      isHide: "1", // 显示此页面
      isLink: "", // 是否外链[有值则是外链]
      isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
      isFull: "1", // 是否缓存全屏[0是，1否]
      isAffix: "1" // 是否缓存固定路由[0是，1否]
    },
    children: [
      {
        path: "/terraria/overview", // [唯一]
        name: "terrariaOverview",
        component: () => import("@/views/terraria/index.vue"),
        meta: {
          title: "服务器概览", // 标题
          icon: "DataLine", // 图标
          isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
          isLink: "", // 是否外链[有值则是外链]
          isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
          isFull: "1", // 是否缓存全屏[0是，1否]
          isAffix: "1" // 是否缓存固定路由[0是，1否]
        }
      },
      {
        path: "/terraria/worlds", // [唯一]
        name: "terrariaWorlds",
        component: () => import("@/views/terraria/worlds.vue"),
        meta: {
          title: "世界管理", // 标题
          icon: "Place", // 图标
          isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
          isLink: "", // 是否外链[有值则是外链]
          isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
          isFull: "1", // 是否缓存全屏[0是，1否]
          isAffix: "1" // 是否缓存固定路由[0是，1否]
        }
      },
      {
        path: "/terraria/players", // [唯一]
        name: "terrariaPlayers",
        component: () => import("@/views/terraria/players.vue"),
        meta: {
          title: "玩家管理", // 标题
          icon: "User", // 图标
          isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
          isLink: "", // 是否外链[有值则是外链]
          isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
          isFull: "1", // 是否缓存全屏[0是，1否]
          isAffix: "1" // 是否缓存固定路由[0是，1否]
        }
      },
      {
        path: "/terraria/config", // [唯一]
        name: "terrariaConfig",
        component: () => import("@/views/terraria/config.vue"),
        meta: {
          title: "服务器配置", // 标题
          icon: "Setting", // 图标
          isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
          isLink: "", // 是否外链[有值则是外链]
          isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
          isFull: "1", // 是否缓存全屏[0是，1否]
          isAffix: "1" // 是否缓存固定路由[0是，1否]
        }
      },
      {
        path: "/terraria/backups", // [唯一]
        name: "terrariaBackups",
        component: () => import("@/views/terraria/backups.vue"),
        meta: {
          title: "备份管理", // 标题
          icon: "CopyDocument", // 图标
          isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
          isLink: "", // 是否外链[有值则是外链]
          isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
          isFull: "1", // 是否缓存全屏[0是，1否]
          isAffix: "1" // 是否缓存固定路由[0是，1否]
        }
      },
      {
        path: "/terraria/plugins", // [唯一]
        name: "terrariaPlugins",
        component: () => import("@/views/terraria/plugins.vue"),
        meta: {
          title: "插件管理", // 标题
          icon: "SetUp", // 图标
          isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
          isLink: "", // 是否外链[有值则是外链]
          isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
          isFull: "1", // 是否缓存全屏[0是，1否]
          isAffix: "1" // 是否缓存固定路由[0是，1否]
        }
      },
      {
        path: "/terraria/logs", // [唯一]
        name: "terrariaLogs",
        component: () => import("@/views/terraria/logs.vue"),
        meta: {
          title: "服务器日志", // 标题
          icon: "Document", // 图标
          isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
          isLink: "", // 是否外链[有值则是外链]
          isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
          isFull: "1", // 是否缓存全屏[0是，1否]
          isAffix: "1" // 是否缓存固定路由[0是，1否]
        }
      },
      {
        path: "/terraria/console", // [唯一]
        name: "terrariaConsole",
        component: () => import("@/views/terraria/console.vue"),
        meta: {
          title: "服务器控制台", // 标题
          icon: "Terminal", // 图标
          isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
          isLink: "", // 是否外链[有值则是外链]
          isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
          isFull: "1", // 是否缓存全屏[0是，1否]
          isAffix: "1" // 是否缓存固定路由[0是，1否]
        }
      }
    ]
  }
];

/**
 * errorRouter (错误页面路由)
 */
export const errorRouter = [
  {
    path: "/403",
    name: "403",
    component: () => import("@/views/error/403.vue"),
    meta: {
      title: "403页面",
      icon: "QuestionFilled", // 菜单图标
      isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
      isLink: "1", // 是否外链[有值则是外链]
      isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
      isFull: "1", // 是否缓存全屏[0是，1否]
      isAffix: "1" // 是否缓存固定路由[0是，1否]
    }
  },
  {
    path: "/404",
    name: "404",
    component: () => import("@/views/error/404.vue"),
    meta: {
      title: "404页面",
      icon: "CircleCloseFilled", // 菜单图标
      isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
      isLink: "1", // 是否外链[有值则是外链]
      isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
      isFull: "1", // 是否缓存全屏[0是，1否]
      isAffix: "1" // 是否缓存固定路由[0是，1否]
    }
  },
  {
    path: "/500",
    name: "500",
    component: () => import("@/views/error/500.vue"),
    meta: {
      title: "500页面",
      icon: "WarningFilled", // 图标
      isHide: "1", // 代表路由在菜单中是否隐藏，是否隐藏[0隐藏，1显示]
      isLink: "1", // 是否外链[有值则是外链]
      isKeepAlive: "0", // 是否缓存路由数据[0是，1否]
      isFull: "1", // 是否缓存全屏[0是，1否]
      isAffix: "1" // 是否缓存固定路由[0是，1否]
    }
  },
  // 找不到path将跳转404页面
  {
    path: "/:pathMatch(.*)*",
    component: () => import("@/views/error/404.vue")
  }
];
