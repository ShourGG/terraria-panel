<template>
  <div class="layout-container">
    <header class="layout-header">
      <h1>泰拉瑞亚服务器管理面板</h1>
    </header>
    <div class="layout-content">
      <aside class="layout-sidebar">
        <ul class="menu">
          <li><router-link to="/terraria/overview">服务器概览</router-link></li>
          <li><router-link to="/terraria/worlds">世界管理</router-link></li>
          <li><router-link to="/terraria/players">玩家管理</router-link></li>
          <li><router-link to="/terraria/config">服务器配置</router-link></li>
          <li><router-link to="/terraria/backups">备份管理</router-link></li>
          <li><router-link to="/terraria/plugins">插件管理</router-link></li>
          <li><router-link to="/terraria/logs">服务器日志</router-link></li>
          <li><router-link to="/terraria/console">服务器控制台</router-link></li>
        </ul>
      </aside>
      <main class="layout-main">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
// 布局组件
</script>

<style scoped>
.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.layout-header {
  background-color: #4caf50;
  color: white;
  padding: 1rem;
}

.layout-content {
  display: flex;
  flex: 1;
}

.layout-sidebar {
  width: 250px;
  background-color: #f5f5f5;
  padding: 1rem;
}

.menu {
  list-style: none;
  padding: 0;
}

.menu li {
  margin-bottom: 0.5rem;
}

.menu a {
  display: block;
  padding: 0.5rem;
  color: #333;
  text-decoration: none;
  border-radius: 4px;
}

.menu a.router-link-active {
  background-color: #e0e0e0;
  font-weight: bold;
}

.layout-main {
  flex: 1;
  padding: 1rem;
  overflow: auto;
}
</style> 