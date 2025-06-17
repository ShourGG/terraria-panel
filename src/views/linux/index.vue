<template>
  <div class="linux-panel-container">
    <el-row :gutter="16">
      <!-- 系统信息卡片 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="8" :xl="8">
        <el-card class="box-card">
          <template #header>
            <div class="card-header">
              <span>系统信息</span>
              <el-button type="primary" size="small" @click="getSystemInfoData">刷新</el-button>
            </div>
          </template>
          <div v-loading="systemInfoLoading">
            <div v-if="systemInfo" class="info-item">
              <div class="item-row">
                <span class="label">主机名:</span>
                <span class="value">{{ systemInfo.hostname }}</span>
              </div>
              <div class="item-row">
                <span class="label">内核:</span>
                <span class="value">{{ systemInfo.kernel }}</span>
              </div>
              <div class="item-row">
                <span class="label">系统类型:</span>
                <span class="value">{{ systemInfo.osType }}</span>
              </div>
              <div class="item-row">
                <span class="label">系统版本:</span>
                <span class="value">{{ systemInfo.osRelease }}</span>
              </div>
              <div class="item-row">
                <span class="label">运行时间:</span>
                <span class="value">{{ formatUptime(systemInfo.uptime) }}</span>
              </div>
              <div class="item-row">
                <span class="label">架构:</span>
                <span class="value">{{ systemInfo.arch }}</span>
              </div>
              <div class="item-row">
                <span class="label">CPU型号:</span>
                <span class="value">{{ systemInfo.cpuModel }}</span>
              </div>
              <div class="item-row">
                <span class="label">CPU核心数:</span>
                <span class="value">{{ systemInfo.cpuCores }}</span>
              </div>
              <div class="item-row">
                <span class="label">总内存:</span>
                <span class="value">{{ formatBytes(systemInfo.totalMemory) }}</span>
              </div>
              <div class="item-row">
                <span class="label">可用内存:</span>
                <span class="value">{{ formatBytes(systemInfo.freeMemory) }}</span>
              </div>
            </div>
            <el-empty v-else description="暂无系统信息" />
          </div>
        </el-card>
      </el-col>
      
      <!-- 资源使用情况 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="16" :xl="16">
        <el-card class="box-card">
          <template #header>
            <div class="card-header">
              <span>资源使用情况</span>
              <el-button type="primary" size="small" @click="getSystemResourcesData">刷新</el-button>
            </div>
          </template>
          <div v-loading="resourcesLoading">
            <el-row :gutter="16" v-if="systemResources">
              <!-- CPU使用率 -->
              <el-col :span="12">
                <div class="resource-chart">
                  <div class="chart-title">CPU使用率</div>
                  <el-progress 
                    type="dashboard" 
                    :percentage="systemResources.cpu.usage" 
                    :color="getCpuColor(systemResources.cpu.usage)"
                    :stroke-width="10" 
                  />
                  <div class="chart-value">{{ systemResources.cpu.usage.toFixed(1) }}%</div>
                  <div class="chart-subtitle">温度: {{ systemResources.cpu.temp }}°C</div>
                </div>
              </el-col>
              
              <!-- 内存使用率 -->
              <el-col :span="12">
                <div class="resource-chart">
                  <div class="chart-title">内存使用率</div>
                  <el-progress 
                    type="dashboard" 
                    :percentage="systemResources.memory.usagePercent" 
                    :color="getMemoryColor(systemResources.memory.usagePercent)"
                    :stroke-width="10" 
                  />
                  <div class="chart-value">{{ systemResources.memory.usagePercent.toFixed(1) }}%</div>
                  <div class="chart-subtitle">
                    已用: {{ formatBytes(systemResources.memory.used) }} / 
                    总计: {{ formatBytes(systemResources.memory.total) }}
                  </div>
                </div>
              </el-col>
              
              <!-- 磁盘使用率 -->
              <el-col :span="12">
                <div class="resource-chart">
                  <div class="chart-title">磁盘使用率</div>
                  <el-progress 
                    type="dashboard" 
                    :percentage="systemResources.disk.usagePercent" 
                    :color="getDiskColor(systemResources.disk.usagePercent)"
                    :stroke-width="10" 
                  />
                  <div class="chart-value">{{ systemResources.disk.usagePercent.toFixed(1) }}%</div>
                  <div class="chart-subtitle">
                    已用: {{ formatBytes(systemResources.disk.used) }} / 
                    总计: {{ formatBytes(systemResources.disk.total) }}
                  </div>
                </div>
              </el-col>
              
              <!-- SWAP使用率 -->
              <el-col :span="12">
                <div class="resource-chart">
                  <div class="chart-title">SWAP使用率</div>
                  <el-progress 
                    type="dashboard" 
                    :percentage="systemResources.swap.usagePercent" 
                    :color="getSwapColor(systemResources.swap.usagePercent)"
                    :stroke-width="10" 
                  />
                  <div class="chart-value">{{ systemResources.swap.usagePercent.toFixed(1) }}%</div>
                  <div class="chart-subtitle">
                    已用: {{ formatBytes(systemResources.swap.used) }} / 
                    总计: {{ formatBytes(systemResources.swap.total) }}
                  </div>
                </div>
              </el-col>
            </el-row>
            <el-empty v-else description="暂无资源信息" />
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
            <el-button type="primary" @click="navigateTo('/linux/processes')">进程管理</el-button>
            <el-button type="primary" @click="navigateTo('/linux/services')">服务管理</el-button>
            <el-button type="primary" @click="navigateTo('/linux/files')">文件管理</el-button>
            <el-button type="primary" @click="navigateTo('/linux/users')">用户管理</el-button>
            <el-button type="primary" @click="navigateTo('/linux/terminal')">终端</el-button>
            <el-button type="primary" @click="navigateTo('/linux/network')">网络配置</el-button>
            <el-button type="primary" @click="navigateTo('/linux/firewall')">防火墙设置</el-button>
            <el-button type="primary" @click="navigateTo('/linux/logs')">日志查看</el-button>
          </div>
        </el-card>
      </el-col>
      
      <!-- 命令执行区域 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="24" :xl="24">
        <el-card class="box-card">
          <template #header>
            <div class="card-header">
              <span>快速命令</span>
            </div>
          </template>
          <div class="command-area">
            <el-input
              v-model="commandInput"
              placeholder="输入Linux命令"
              clearable
              @keyup.enter="executeCmd"
            >
              <template #append>
                <el-button @click="executeCmd" :loading="commandLoading">执行</el-button>
              </template>
            </el-input>
            
            <div class="command-output" v-if="commandResult">
              <div class="output-header">
                <span>命令输出</span>
                <span>退出码: {{ commandResult.exitCode }}</span>
                <span>执行时间: {{ commandResult.executionTime }}ms</span>
              </div>
              <el-tabs type="border-card">
                <el-tab-pane label="标准输出">
                  <pre>{{ commandResult.stdout || '无输出' }}</pre>
                </el-tab-pane>
                <el-tab-pane label="错误输出">
                  <pre>{{ commandResult.stderr || '无错误' }}</pre>
                </el-tab-pane>
              </el-tabs>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { getSystemInfo, getSystemResources, executeCommand } from '@/api/system/linux';
import type { SystemInfo, SystemResources, CommandResult } from '@/api/system/linux/type';

// 路由
const router = useRouter();

// 数据加载状态
const systemInfoLoading = ref(false);
const resourcesLoading = ref(false);
const commandLoading = ref(false);

// 数据对象
const systemInfo = ref<SystemInfo | null>(null);
const systemResources = ref<SystemResources | null>(null);
const commandInput = ref('');
const commandResult = ref<CommandResult | null>(null);

// 定时刷新
let refreshTimer: number | null = null;

// 获取系统信息
const getSystemInfoData = async () => {
  try {
    systemInfoLoading.value = true;
    const res = await getSystemInfo();
    systemInfo.value = res.data;
  } catch (error) {
    console.error('获取系统信息失败:', error);
  } finally {
    systemInfoLoading.value = false;
  }
};

// 获取资源使用情况
const getSystemResourcesData = async () => {
  try {
    resourcesLoading.value = true;
    const res = await getSystemResources();
    systemResources.value = res.data;
  } catch (error) {
    console.error('获取系统资源信息失败:', error);
  } finally {
    resourcesLoading.value = false;
  }
};

// 执行命令
const executeCmd = async () => {
  if (!commandInput.value) return;
  
  try {
    commandLoading.value = true;
    const res = await executeCommand(commandInput.value);
    commandResult.value = res.data;
  } catch (error) {
    console.error('执行命令失败:', error);
  } finally {
    commandLoading.value = false;
  }
};

// 页面跳转
const navigateTo = (path: string) => {
  router.push(path);
};

// 格式化字节单位
const formatBytes = (bytes: number): string => {
  if (bytes === 0) return '0 B';
  
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// 格式化运行时间
const formatUptime = (seconds: number): string => {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  
  let result = '';
  if (days > 0) result += `${days}天 `;
  if (hours > 0 || days > 0) result += `${hours}小时 `;
  result += `${minutes}分钟`;
  
  return result;
};

// 根据使用率获取颜色
const getCpuColor = (usage: number): string => {
  if (usage < 60) return '#67c23a';
  if (usage < 80) return '#e6a23c';
  return '#f56c6c';
};

const getMemoryColor = (usage: number): string => {
  if (usage < 70) return '#67c23a';
  if (usage < 85) return '#e6a23c';
  return '#f56c6c';
};

const getDiskColor = (usage: number): string => {
  if (usage < 75) return '#67c23a';
  if (usage < 90) return '#e6a23c';
  return '#f56c6c';
};

const getSwapColor = (usage: number): string => {
  if (usage < 50) return '#67c23a';
  if (usage < 70) return '#e6a23c';
  return '#f56c6c';
};

// 启动定时刷新
const startRefreshTimer = () => {
  refreshTimer = window.setInterval(() => {
    getSystemInfoData();
    getSystemResourcesData();
  }, 30000); // 每30秒刷新一次
};

// 生命周期钩子
onMounted(() => {
  getSystemInfoData();
  getSystemResourcesData();
  startRefreshTimer();
});

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer);
    refreshTimer = null;
  }
});
</script>

<style lang="scss" scoped>
.linux-panel-container {
  padding: 16px;
}

.box-card {
  margin-bottom: 16px;
  
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}

.info-item {
  .item-row {
    display: flex;
    margin-bottom: 8px;
    
    .label {
      flex: 0 0 100px;
      font-weight: bold;
      color: #606266;
    }
    
    .value {
      flex: 1;
    }
  }
}

.resource-chart {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 20px;
  
  .chart-title {
    font-size: 16px;
    font-weight: bold;
    margin-bottom: 10px;
  }
  
  .chart-value {
    margin-top: 8px;
    font-size: 18px;
    font-weight: bold;
  }
  
  .chart-subtitle {
    margin-top: 4px;
    font-size: 12px;
    color: #909399;
  }
}

.quick-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.command-area {
  .command-output {
    margin-top: 16px;
    border: 1px solid #e4e7ed;
    border-radius: 4px;
    
    .output-header {
      display: flex;
      justify-content: space-between;
      padding: 8px 16px;
      background-color: #f5f7fa;
      border-bottom: 1px solid #e4e7ed;
    }
    
    pre {
      padding: 10px;
      margin: 0;
      overflow-x: auto;
      font-family: monospace;
      white-space: pre-wrap;
      background-color: #f8f8f8;
      max-height: 300px;
      overflow-y: auto;
    }
  }
}
</style> 