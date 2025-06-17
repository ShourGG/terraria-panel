<template>
  <div class="terraria-panel-container">
    <el-row :gutter="16">
      <!-- 服务器状态卡片 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="8" :xl="8">
        <el-card class="box-card">
          <template #header>
            <div class="card-header">
              <span>服务器状态</span>
              <el-button type="primary" size="small" @click="getServerStatusData">刷新</el-button>
            </div>
          </template>
          <div v-loading="statusLoading">
            <div v-if="serverStatus" class="server-status">
              <div class="status-indicator">
                <div class="status-dot" :class="getStatusClass(serverStatus.status)"></div>
                <span class="status-text">{{ getStatusText(serverStatus.status) }}</span>
              </div>
              
              <div class="info-item">
                <div class="item-row">
                  <span class="label">版本:</span>
                  <span class="value">{{ serverStatus.version }}</span>
                </div>
                <div class="item-row">
                  <span class="label">世界:</span>
                  <span class="value">{{ serverStatus.worldName || '未选择' }}</span>
                </div>
                <div class="item-row">
                  <span class="label">难度:</span>
                  <span class="value">{{ serverStatus.difficulty }}</span>
                </div>
                <div class="item-row">
                  <span class="label">玩家数:</span>
                  <span class="value">{{ serverStatus.players?.length || 0 }} / {{ serverStatus.maxPlayers }}</span>
                </div>
                <div class="item-row">
                  <span class="label">端口:</span>
                  <span class="value">{{ serverStatus.port }}</span>
                </div>
                <div class="item-row">
                  <span class="label">运行时间:</span>
                  <span class="value">{{ formatUptime(serverStatus.uptime) }}</span>
                </div>
                <div class="item-row">
                  <span class="label">CPU使用率:</span>
                  <span class="value">{{ serverStatus.cpuUsage.toFixed(1) }}%</span>
                </div>
                <div class="item-row">
                  <span class="label">内存使用:</span>
                  <span class="value">{{ formatBytes(serverStatus.memoryUsage) }}</span>
                </div>
              </div>
              
              <div class="server-controls">
                <el-button 
                  type="success" 
                  :disabled="serverStatus.status === 'running' || serverStatus.status === 'starting'"
                  @click="handleStartServer"
                  :loading="controlLoading"
                >
                  启动服务器
                </el-button>
                <el-button 
                  type="danger" 
                  :disabled="serverStatus.status === 'stopped'"
                  @click="handleStopServer"
                  :loading="controlLoading"
                >
                  停止服务器
                </el-button>
                <el-button 
                  type="warning"
                  :disabled="serverStatus.status !== 'running'"
                  @click="handleRestartServer"
                  :loading="controlLoading"
                >
                  重启服务器
                </el-button>
              </div>
            </div>
            <el-empty v-else description="暂无服务器信息" />
          </div>
        </el-card>
      </el-col>
      
      <!-- 玩家列表卡片 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="16" :xl="16">
        <el-card class="box-card">
          <template #header>
            <div class="card-header">
              <span>在线玩家 ({{ serverStatus?.players?.length || 0 }})</span>
              <el-button type="primary" size="small" @click="getServerStatusData">刷新</el-button>
            </div>
          </template>
          <div v-loading="statusLoading">
            <el-table v-if="serverStatus?.players?.length" :data="serverStatus.players" style="width: 100%">
              <el-table-column prop="id" label="ID" width="60" />
              <el-table-column prop="name" label="玩家名称" />
              <el-table-column prop="ip" label="IP地址" />
              <el-table-column prop="joinTime" label="加入时间" />
              <el-table-column prop="health" label="生命值">
                <template #default="scope">
                  <el-progress 
                    :percentage="(scope.row.health / scope.row.maxHealth) * 100" 
                    :format="() => `${scope.row.health}/${scope.row.maxHealth}`"
                    :color="getHealthColor(scope.row.health, scope.row.maxHealth)"
                  />
                </template>
              </el-table-column>
              <el-table-column label="操作" width="150">
                <template #default="scope">
                  <el-button 
                    type="danger" 
                    size="small" 
                    @click="handleKickPlayer(scope.row.id)"
                    :loading="playerActionLoading === scope.row.id"
                  >
                    踢出
                  </el-button>
                  <el-button 
                    type="warning" 
                    size="small" 
                    @click="handleBanPlayer(scope.row.id)"
                    :loading="playerActionLoading === scope.row.id"
                  >
                    封禁
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
            <el-empty v-else description="暂无在线玩家" />
          </div>
        </el-card>
      </el-col>
      
      <!-- 快捷操作面板 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="24" :xl="24">
        <el-card class="box-card">
          <template #header>
            <div class="card-header">
              <span>快捷操作</span>
            </div>
          </template>
          <div class="quick-actions">
            <el-button type="primary" @click="navigateTo('/terraria/worlds')">世界管理</el-button>
            <el-button type="primary" @click="navigateTo('/terraria/players')">玩家管理</el-button>
            <el-button type="primary" @click="navigateTo('/terraria/config')">服务器配置</el-button>
            <el-button type="primary" @click="navigateTo('/terraria/backups')">备份管理</el-button>
            <el-button type="primary" @click="navigateTo('/terraria/plugins')">插件管理</el-button>
            <el-button type="primary" @click="navigateTo('/terraria/logs')">服务器日志</el-button>
            <el-button type="primary" @click="navigateTo('/terraria/console')">服务器控制台</el-button>
            <el-button type="primary" @click="createBackupNow">立即备份</el-button>
          </div>
        </el-card>
      </el-col>
      
      <!-- 服务器消息 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="24" :xl="24">
        <el-card class="box-card">
          <template #header>
            <div class="card-header">
              <span>发送服务器消息</span>
            </div>
          </template>
          <div class="message-area">
            <el-input
              v-model="messageInput"
              placeholder="输入服务器消息"
              clearable
              @keyup.enter="sendMessage"
            >
              <template #append>
                <el-button @click="sendMessage" :loading="messageLoading">发送</el-button>
              </template>
            </el-input>
          </div>
        </el-card>
      </el-col>
      
      <!-- 服务器日志 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="24" :xl="24">
        <el-card class="box-card">
          <template #header>
            <div class="card-header">
              <span>最近日志</span>
              <el-button type="primary" size="small" @click="getServerLogs">刷新</el-button>
            </div>
          </template>
          <div class="logs-area" v-loading="logsLoading">
            <div v-if="serverLogs?.length" class="log-entries">
              <div 
                v-for="(log, index) in serverLogs" 
                :key="index" 
                class="log-entry"
                :class="getLogLevelClass(log.level)"
              >
                <span class="log-timestamp">{{ log.timestamp }}</span>
                <span class="log-level">[{{ log.level.toUpperCase() }}]</span>
                <span class="log-message">{{ log.message }}</span>
              </div>
            </div>
            <el-empty v-else description="暂无日志" />
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { 
  getServerStatus, 
  startServer, 
  stopServer, 
  restartServer,
  kickPlayer,
  banPlayer,
  sendServerMessage,
  getServerLogs as fetchServerLogs,
  createBackup
} from '@/api/system/terraria';
import type { TerrariaServerInfo, TerrariaLogEntry } from '@/api/system/terraria/type';
import { ElMessage, ElMessageBox } from 'element-plus';

// 路由
const router = useRouter();

// 数据加载状态
const statusLoading = ref(false);
const controlLoading = ref(false);
const playerActionLoading = ref<number | null>(null);
const messageLoading = ref(false);
const logsLoading = ref(false);

// 数据对象
const serverStatus = ref<TerrariaServerInfo | null>(null);
const serverLogs = ref<TerrariaLogEntry[]>([]);
const messageInput = ref('');

// 定时刷新
let refreshTimer: number | null = null;

// 获取服务器状态
const getServerStatusData = async () => {
  try {
    statusLoading.value = true;
    const res = await getServerStatus();
    serverStatus.value = res.data;
  } catch (error) {
    console.error('获取服务器状态失败:', error);
  } finally {
    statusLoading.value = false;
  }
};

// 获取服务器状态类名
const getStatusClass = (status: string) => {
  switch (status) {
    case 'running':
      return 'status-running';
    case 'starting':
      return 'status-starting';
    case 'stopped':
      return 'status-stopped';
    case 'error':
      return 'status-error';
    default:
      return 'status-unknown';
  }
};

// 获取服务器状态文本
const getStatusText = (status: string) => {
  switch (status) {
    case 'running':
      return '运行中';
    case 'starting':
      return '启动中';
    case 'stopped':
      return '已停止';
    case 'error':
      return '错误';
    default:
      return '未知状态';
  }
};

// 获取健康条颜色
const getHealthColor = (health: number, maxHealth: number) => {
  const percent = (health / maxHealth) * 100;
  if (percent < 30) return '#F56C6C';
  if (percent < 70) return '#E6A23C';
  return '#67C23A';
};

// 获取日志级别类名
const getLogLevelClass = (level: string) => {
  switch (level) {
    case 'error':
      return 'log-error';
    case 'warning':
      return 'log-warning';
    case 'info':
      return 'log-info';
    default:
      return '';
  }
};

// 启动服务器
const handleStartServer = async () => {
  try {
    controlLoading.value = true;
    await startServer();
    ElMessage.success('服务器正在启动');
    setTimeout(() => {
      getServerStatusData();
    }, 2000);
  } catch (error) {
    console.error('启动服务器失败:', error);
    ElMessage.error('启动服务器失败');
  } finally {
    controlLoading.value = false;
  }
};

// 停止服务器
const handleStopServer = async () => {
  try {
    await ElMessageBox.confirm('确定要停止服务器吗？这将断开所有玩家的连接。', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    
    controlLoading.value = true;
    await stopServer();
    ElMessage.success('服务器已停止');
    setTimeout(() => {
      getServerStatusData();
    }, 2000);
  } catch (error) {
    if (error !== 'cancel') {
      console.error('停止服务器失败:', error);
      ElMessage.error('停止服务器失败');
    }
  } finally {
    controlLoading.value = false;
  }
};

// 重启服务器
const handleRestartServer = async () => {
  try {
    await ElMessageBox.confirm('确定要重启服务器吗？这将暂时断开所有玩家的连接。', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    
    controlLoading.value = true;
    await restartServer();
    ElMessage.success('服务器正在重启');
    setTimeout(() => {
      getServerStatusData();
    }, 5000);
  } catch (error) {
    if (error !== 'cancel') {
      console.error('重启服务器失败:', error);
      ElMessage.error('重启服务器失败');
    }
  } finally {
    controlLoading.value = false;
  }
};

// 踢出玩家
const handleKickPlayer = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要踢出该玩家吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    
    playerActionLoading.value = id;
    await kickPlayer(id);
    ElMessage.success('已踢出玩家');
    getServerStatusData();
  } catch (error) {
    if (error !== 'cancel') {
      console.error('踢出玩家失败:', error);
      ElMessage.error('踢出玩家失败');
    }
  } finally {
    playerActionLoading.value = null;
  }
};

// 封禁玩家
const handleBanPlayer = async (id: number) => {
  try {
    await ElMessageBox.confirm('确定要封禁该玩家吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    
    playerActionLoading.value = id;
    await banPlayer(id);
    ElMessage.success('已封禁玩家');
    getServerStatusData();
  } catch (error) {
    if (error !== 'cancel') {
      console.error('封禁玩家失败:', error);
      ElMessage.error('封禁玩家失败');
    }
  } finally {
    playerActionLoading.value = null;
  }
};

// 发送服务器消息
const sendMessage = async () => {
  if (!messageInput.value.trim()) return;
  
  try {
    messageLoading.value = true;
    await sendServerMessage(messageInput.value);
    ElMessage.success('消息已发送');
    messageInput.value = '';
  } catch (error) {
    console.error('发送消息失败:', error);
    ElMessage.error('发送消息失败');
  } finally {
    messageLoading.value = false;
  }
};

// 获取服务器日志
const getServerLogs = async () => {
  try {
    logsLoading.value = true;
    const res = await fetchServerLogs(50);
    serverLogs.value = res.data;
  } catch (error) {
    console.error('获取服务器日志失败:', error);
  } finally {
    logsLoading.value = false;
  }
};

// 立即创建备份
const createBackupNow = async () => {
  try {
    await ElMessageBox.prompt('请输入备份说明 (可选)', '创建备份', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
    });
    
    const { value: note } = await ElMessageBox.prompt('请输入备份说明 (可选)', '创建备份', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
    });
    
    ElMessage.info('正在创建备份...');
    await createBackup(note);
    ElMessage.success('备份创建成功');
  } catch (error) {
    if (error !== 'cancel') {
      console.error('创建备份失败:', error);
      ElMessage.error('创建备份失败');
    }
  }
};

// 路由导航
const navigateTo = (path: string) => {
  router.push(path);
};

// 格式化运行时间
const formatUptime = (seconds: number): string => {
  if (!seconds) return '0秒';
  
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const remainingSeconds = Math.floor(seconds % 60);
  
  let result = '';
  if (days > 0) result += `${days}天 `;
  if (hours > 0) result += `${hours}小时 `;
  if (minutes > 0) result += `${minutes}分钟 `;
  if (remainingSeconds > 0) result += `${remainingSeconds}秒`;
  
  return result.trim();
};

// 格式化字节大小
const formatBytes = (bytes: number): string => {
  if (bytes === 0) return '0 B';
  
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// 生命周期钩子
onMounted(() => {
  getServerStatusData();
  getServerLogs();
  
  // 定时刷新状态
  refreshTimer = window.setInterval(() => {
    getServerStatusData();
  }, 10000);
});

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer);
  }
});
</script>

<style scoped>
.terraria-panel-container {
  padding: 20px;
}

.box-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.server-status {
  padding: 10px 0;
}

.status-indicator {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.status-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 8px;
}

.status-running {
  background-color: #67C23A;
  box-shadow: 0 0 5px #67C23A;
}

.status-starting {
  background-color: #E6A23C;
  box-shadow: 0 0 5px #E6A23C;
  animation: blink 1s infinite;
}

.status-stopped {
  background-color: #909399;
}

.status-error {
  background-color: #F56C6C;
  box-shadow: 0 0 5px #F56C6C;
}

.status-text {
  font-weight: bold;
}

.info-item {
  margin-bottom: 15px;
}

.item-row {
  display: flex;
  margin-bottom: 8px;
}

.label {
  width: 100px;
  color: #606266;
}

.value {
  flex: 1;
  font-weight: 500;
}

.server-controls {
  display: flex;
  justify-content: space-between;
  margin-top: 15px;
}

.quick-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.message-area {
  margin-bottom: 15px;
}

.logs-area {
  height: 300px;
  overflow-y: auto;
  background-color: #f5f7fa;
  border-radius: 4px;
  padding: 10px;
}

.log-entries {
  font-family: monospace;
}

.log-entry {
  padding: 4px 0;
  border-bottom: 1px solid #ebeef5;
}

.log-timestamp {
  color: #909399;
  margin-right: 10px;
}

.log-level {
  font-weight: bold;
  margin-right: 10px;
}

.log-error .log-level {
  color: #F56C6C;
}

.log-warning .log-level {
  color: #E6A23C;
}

.log-info .log-level {
  color: #409EFF;
}

.log-message {
  white-space: pre-wrap;
}

@keyframes blink {
  0% { opacity: 0.5; }
  50% { opacity: 1; }
  100% { opacity: 0.5; }
}
</style> 