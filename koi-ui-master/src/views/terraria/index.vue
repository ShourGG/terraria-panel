<template>
  <div class="terraria-overview">
    <h2>服务器概览</h2>
    <div class="server-status">
      <h3>服务器状态</h3>
      <p>状态: {{ serverInfo.status }}</p>
      <div class="controls">
        <el-button type="primary" @click="startServer" :disabled="serverInfo.status === 'running'">启动服务器</el-button>
        <el-button type="danger" @click="stopServer" :disabled="serverInfo.status === 'stopped'">停止服务器</el-button>
        <el-button type="warning" @click="restartServer" :disabled="serverInfo.status === 'stopped'">重启服务器</el-button>
      </div>
    </div>
    
    <div class="server-info">
      <h3>服务器信息</h3>
      <p>版本: {{ serverInfo.version }}</p>
      <p>世界: {{ serverInfo.worldName }}</p>
      <p>端口: {{ serverInfo.port }}</p>
      <p>难度: {{ serverInfo.difficulty }}</p>
      <p>运行时间: {{ formatUptime(serverInfo.uptime) }}</p>
      <p>内存使用: {{ formatBytes(serverInfo.memoryUsage) }}</p>
      <p>CPU使用率: {{ serverInfo.cpuUsage }}%</p>
    </div>
    
    <div class="player-list">
      <h3>在线玩家 ({{ serverInfo.players.length }}/{{ serverInfo.maxPlayers }})</h3>
      <el-table :data="serverInfo.players" style="width: 100%">
        <el-table-column prop="id" label="ID" width="50" />
        <el-table-column prop="name" label="玩家名称" />
        <el-table-column prop="ip" label="IP地址" />
        <el-table-column prop="joinTime" label="加入时间" />
        <el-table-column label="生命值">
          <template #default="scope">
            {{ scope.row.health }}/{{ scope.row.maxHealth }}
          </template>
        </el-table-column>
        <el-table-column label="操作">
          <template #default="scope">
            <el-button size="small" @click="kickPlayer(scope.row.id)">踢出</el-button>
            <el-button size="small" type="danger" @click="banPlayer(scope.row.id)">封禁</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
    
    <div class="server-console">
      <h3>服务器控制台</h3>
      <div class="console-output">
        <p v-for="(log, index) in logs" :key="index" :class="log.level">
          [{{ log.timestamp }}] {{ log.message }}
        </p>
      </div>
      <div class="console-input">
        <el-input 
          v-model="command" 
          placeholder="输入服务器命令..." 
          @keyup.enter="executeCommand"
        >
          <template #append>
            <el-button @click="executeCommand">执行</el-button>
          </template>
        </el-input>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { ElMessage } from 'element-plus';
import { 
  getServerStatus, 
  startServer as startServerApi, 
  stopServer as stopServerApi, 
  restartServer as restartServerApi,
  getServerLogs,
  executeServerCommand,
  kickPlayer as kickPlayerApi,
  banPlayer as banPlayerApi
} from '@/api/system/terraria';

// 服务器信息
const serverInfo = ref({
  status: 'unknown',
  version: '',
  worldName: '',
  players: [],
  maxPlayers: 0,
  uptime: 0,
  port: 0,
  difficulty: '',
  memoryUsage: 0,
  cpuUsage: 0
});

// 日志
const logs = ref([]);
const command = ref('');

// 定时器
let statusTimer = null;
let logsTimer = null;

// 获取服务器状态
const fetchServerStatus = async () => {
  try {
    const response = await getServerStatus();
    serverInfo.value = response.data;
  } catch (error) {
    console.error('获取服务器状态失败:', error);
  }
};

// 获取服务器日志
const fetchServerLogs = async () => {
  try {
    const response = await getServerLogs(50);
    logs.value = response.data;
  } catch (error) {
    console.error('获取服务器日志失败:', error);
  }
};

// 启动服务器
const startServer = async () => {
  try {
    await startServerApi();
    ElMessage.success('服务器启动命令已发送');
    fetchServerStatus();
  } catch (error) {
    ElMessage.error('启动服务器失败');
  }
};

// 停止服务器
const stopServer = async () => {
  try {
    await stopServerApi();
    ElMessage.success('服务器停止命令已发送');
    fetchServerStatus();
  } catch (error) {
    ElMessage.error('停止服务器失败');
  }
};

// 重启服务器
const restartServer = async () => {
  try {
    await restartServerApi();
    ElMessage.success('服务器重启命令已发送');
    fetchServerStatus();
  } catch (error) {
    ElMessage.error('重启服务器失败');
  }
};

// 踢出玩家
const kickPlayer = async (playerId) => {
  try {
    await kickPlayerApi(playerId);
    ElMessage.success('玩家已被踢出');
    fetchServerStatus();
  } catch (error) {
    ElMessage.error('踢出玩家失败');
  }
};

// 封禁玩家
const banPlayer = async (playerId) => {
  try {
    await banPlayerApi(playerId);
    ElMessage.success('玩家已被封禁');
    fetchServerStatus();
  } catch (error) {
    ElMessage.error('封禁玩家失败');
  }
};

// 执行命令
const executeCommand = async () => {
  if (!command.value) return;
  
  try {
    await executeServerCommand(command.value);
    command.value = '';
    // 执行命令后获取最新日志
    setTimeout(fetchServerLogs, 500);
  } catch (error) {
    ElMessage.error('执行命令失败');
  }
};

// 格式化运行时间
const formatUptime = (seconds) => {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const remainingSeconds = seconds % 60;
  
  return `${days}天 ${hours}时 ${minutes}分 ${remainingSeconds}秒`;
};

// 格式化字节
const formatBytes = (bytes) => {
  if (bytes === 0) return '0 B';
  
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

onMounted(() => {
  // 初始获取数据
  fetchServerStatus();
  fetchServerLogs();
  
  // 设置定时刷新
  statusTimer = setInterval(fetchServerStatus, 5000);
  logsTimer = setInterval(fetchServerLogs, 10000);
});

onUnmounted(() => {
  // 清除定时器
  clearInterval(statusTimer);
  clearInterval(logsTimer);
});
</script>

<style scoped>
.terraria-overview {
  padding: 20px;
}

h2 {
  margin-bottom: 20px;
  color: #4caf50;
}

h3 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #333;
}

.server-status, .server-info, .player-list, .server-console {
  background-color: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.controls {
  margin-top: 15px;
}

.console-output {
  height: 300px;
  overflow-y: auto;
  background-color: #f5f5f5;
  border-radius: 4px;
  padding: 10px;
  margin-bottom: 10px;
  font-family: 'Courier New', monospace;
}

.console-output p {
  margin: 5px 0;
  white-space: pre-wrap;
  word-break: break-all;
}

.console-output .info {
  color: #333;
}

.console-output .warn {
  color: #ff9800;
}

.console-output .error {
  color: #f44336;
}

.console-output .debug {
  color: #9e9e9e;
}

.console-input {
  margin-top: 10px;
}
</style> 