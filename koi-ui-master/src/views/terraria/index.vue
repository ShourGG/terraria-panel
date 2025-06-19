<template>
  <div>
    <el-row :gutter="16">
      <!-- 服务器状态卡片 -->
      <el-col :xs="24" :sm="24" :md="12" :lg="8" :xl="8">
        <KoiCard header="服务器状态" icon="Monitor">
          <template #headerBtn>
            <el-button type="primary" size="small" @click="getServerStatusData">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
          </template>
          <div v-loading="statusLoading">
            <div v-if="serverStatus" class="server-status">
              <div class="status-indicator">
                <div class="status-dot" :class="getStatusClass(serverStatus.status)"></div>
                <span class="status-text">{{ getStatusText(serverStatus.status) }}</span>
              </div>
              
              <el-descriptions :column="1" border>
                <el-descriptions-item label="版本">
                  {{ serverStatus.version }}
                </el-descriptions-item>
                <el-descriptions-item label="世界">
                  {{ serverStatus.worldName || '未选择' }}
                </el-descriptions-item>
                <el-descriptions-item label="难度">
                  {{ serverStatus.difficulty }}
                </el-descriptions-item>
                <el-descriptions-item label="玩家数">
                  {{ serverStatus.players?.length || 0 }} / {{ serverStatus.maxPlayers }}
                </el-descriptions-item>
                <el-descriptions-item label="端口">
                  {{ serverStatus.port }}
                </el-descriptions-item>
                <el-descriptions-item label="运行时间">
                  {{ formatUptime(serverStatus.uptime) }}
                </el-descriptions-item>
                <el-descriptions-item label="CPU使用率">
                  <el-progress 
                    :percentage="serverStatus?.cpuUsage || 0" 
                    :stroke-width="10" 
                    :format="() => (serverStatus?.cpuUsage || 0).toFixed(1) + '%'" 
                  />
                </el-descriptions-item>
                <el-descriptions-item label="内存使用">
                  {{ formatBytes(serverStatus.memoryUsage) }}
                </el-descriptions-item>
              </el-descriptions>
              
              <div class="server-controls mt-4">
                <el-button 
                  type="success" 
                  :disabled="serverStatus.status === 'running' || serverStatus.status === 'starting'"
                  @click="handleStartServer"
                  :loading="controlLoading"
                >
                  <el-icon><VideoPlay /></el-icon>
                  启动服务器
                </el-button>
                <el-button 
                  type="danger" 
                  :disabled="serverStatus.status === 'stopped'"
                  @click="handleStopServer"
                  :loading="controlLoading"
                >
                  <el-icon><VideoPause /></el-icon>
                  停止服务器
                </el-button>
                <el-button 
                  type="warning"
                  :disabled="serverStatus.status !== 'running'"
                  @click="handleRestartServer"
                  :loading="controlLoading"
                >
                  <el-icon><RefreshRight /></el-icon>
                  重启服务器
                </el-button>
              </div>
            </div>
            <el-empty v-else description="暂无服务器信息" />
          </div>
        </KoiCard>
      </el-col>
      
      <!-- 系统信息卡片 -->
      <el-col :xs="24" :sm="24" :md="12" :lg="8" :xl="8">
        <KoiCard header="系统信息" icon="Cpu">
          <template #headerBtn>
            <el-button type="primary" size="small" @click="getSystemInfo">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
          </template>
          <div v-loading="systemInfoLoading">
            <el-descriptions :column="1" border>
              <el-descriptions-item label="操作系统">
                {{ systemInfo.os || '未知' }}
              </el-descriptions-item>
              <el-descriptions-item label="系统架构">
                {{ systemInfo.arch || '未知' }}
              </el-descriptions-item>
              <el-descriptions-item label="CPU型号">
                {{ systemInfo.cpuModel || '未知' }}
              </el-descriptions-item>
              <el-descriptions-item label="CPU核心数">
                {{ systemInfo.cpuCores || '未知' }}
              </el-descriptions-item>
              <el-descriptions-item label="CPU使用率">
                <el-progress 
                  :percentage="systemInfo.cpuUsage || 0" 
                  :stroke-width="10" 
                  :format="() => (systemInfo.cpuUsage || 0).toFixed(1) + '%'" 
                />
              </el-descriptions-item>
              <el-descriptions-item label="内存总量">
                {{ formatBytes(systemInfo.totalMem) }}
              </el-descriptions-item>
              <el-descriptions-item label="内存使用">
                <el-progress 
                  :percentage="systemInfo.memUsage || 0" 
                  :stroke-width="10" 
                  :format="() => (systemInfo.memUsage || 0).toFixed(1) + '%'" 
                />
              </el-descriptions-item>
              <el-descriptions-item label="磁盘使用">
                <el-progress 
                  :percentage="systemInfo.diskUsage || 0" 
                  :stroke-width="10" 
                  :format="() => (systemInfo.diskUsage || 0).toFixed(1) + '%'" 
                />
              </el-descriptions-item>
            </el-descriptions>
          </div>
        </KoiCard>
      </el-col>
      
      <!-- 房间信息卡片 -->
      <el-col :xs="24" :sm="24" :md="12" :lg="8" :xl="8">
        <KoiCard header="房间信息" icon="House">
          <template #headerBtn>
            <el-button type="primary" size="small" @click="getRoomInfo">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
          </template>
          <div v-loading="roomInfoLoading">
            <el-descriptions :column="1" border>
              <el-descriptions-item label="房间名称">
                {{ roomInfo.name || '未设置' }}
              </el-descriptions-item>
              <el-descriptions-item label="房间密码">
                {{ roomInfo.password ? '已设置' : '未设置' }}
                <el-button v-if="roomInfo.password" type="text" @click="showPassword = !showPassword">
                  {{ showPassword ? '隐藏' : '显示' }}
                </el-button>
                <span v-if="showPassword && roomInfo.password">{{ roomInfo.password }}</span>
              </el-descriptions-item>
              <el-descriptions-item label="最大人数">
                {{ roomInfo.maxPlayers || '未设置' }}
              </el-descriptions-item>
              <el-descriptions-item label="房间状态">
                <el-tag :type="roomInfo.isPublic ? 'success' : 'info'">
                  {{ roomInfo.isPublic ? '公开' : '私有' }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="创建时间">
                {{ roomInfo.createdAt || '未知' }}
              </el-descriptions-item>
              <el-descriptions-item label="房间描述">
                {{ roomInfo.description || '无描述' }}
              </el-descriptions-item>
            </el-descriptions>
            <div class="mt-4">
              <el-button type="primary" @click="editRoomInfo">
                <el-icon><Edit /></el-icon>
                编辑房间信息
              </el-button>
            </div>
          </div>
        </KoiCard>
      </el-col>
      
      <!-- 玩家列表卡片 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="16" :xl="16">
        <KoiCard header="在线玩家" icon="User">
          <template #headerBtn>
            <span class="player-count">{{ serverStatus?.players?.length || 0 }}人在线</span>
            <el-button type="primary" size="small" @click="getServerStatusData">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
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
        </KoiCard>
      </el-col>
      
      <!-- 控制面板 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="8" :xl="8">
        <KoiCard header="控制面板" icon="SetUp">
          <div class="control-panel">
            <el-row :gutter="10">
              <el-col :span="12">
                <el-button type="success" @click="handleDayTime" :disabled="!serverStatus || serverStatus.status !== 'running'">
                  <el-icon><Sunny /></el-icon>
                  设置白天
                </el-button>
              </el-col>
              <el-col :span="12">
                <el-button type="info" @click="handleNightTime" :disabled="!serverStatus || serverStatus.status !== 'running'">
                  <el-icon><Moon /></el-icon>
                  设置黑夜
                </el-button>
              </el-col>
            </el-row>
            <el-divider />
            <el-row :gutter="10">
              <el-col :span="12">
                <el-button type="primary" @click="handleRain" :disabled="!serverStatus || serverStatus.status !== 'running'">
                  <el-icon><Cloudy /></el-icon>
                  开启雨天
                </el-button>
              </el-col>
              <el-col :span="12">
                <el-button type="warning" @click="handleStopRain" :disabled="!serverStatus || serverStatus.status !== 'running'">
                  <el-icon><Sunny /></el-icon>
                  停止雨天
                </el-button>
              </el-col>
            </el-row>
            <el-divider />
            <el-row :gutter="10">
              <el-col :span="24">
                <el-button type="danger" @click="handleSpawnBoss" :disabled="!serverStatus || serverStatus.status !== 'running'">
                  <el-icon><Warning /></el-icon>
                  召唤Boss
                </el-button>
              </el-col>
            </el-row>
            <el-divider />
            <el-row :gutter="10">
              <el-col :span="12">
                <el-button type="success" @click="handlePvPOn" :disabled="!serverStatus || serverStatus.status !== 'running'">
                  <el-icon><DArrowRight /></el-icon>
                  开启PvP
                </el-button>
              </el-col>
              <el-col :span="12">
                <el-button type="info" @click="handlePvPOff" :disabled="!serverStatus || serverStatus.status !== 'running'">
                  <el-icon><DArrowLeft /></el-icon>
                  关闭PvP
                </el-button>
              </el-col>
            </el-row>
            <el-divider />
            <el-row :gutter="10">
              <el-col :span="24">
                <el-button type="warning" @click="handleSaveWorld" :disabled="!serverStatus || serverStatus.status !== 'running'">
                  <el-icon><Download /></el-icon>
                  保存世界
                </el-button>
              </el-col>
            </el-row>
          </div>
        </KoiCard>
      </el-col>
      
      <!-- 命令执行卡片 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="12" :xl="12">
        <KoiCard header="命令执行" icon="Terminal">
          <div class="command-area">
            <el-input
              v-model="commandInput"
              placeholder="输入命令，例如: /help"
              clearable
              @keyup.enter="executeCommand"
            >
              <template #prepend>
                <el-select v-model="commandType" style="width: 120px">
                  <el-option label="服务器命令" value="server" />
                  <el-option label="系统命令" value="system" />
                </el-select>
              </template>
              <template #append>
                <el-button @click="executeCommand" :loading="commandLoading">执行</el-button>
              </template>
            </el-input>
            
            <div class="command-history mt-3">
              <div class="command-history-header">
                <span>命令历史</span>
                <el-button type="text" @click="clearCommandHistory">清空</el-button>
              </div>
              <div class="command-history-content">
                <div v-for="(item, index) in commandHistory" :key="index" class="command-history-item">
                  <div class="command-input">
                    <span class="command-type">{{ item.type === 'server' ? '服务器' : '系统' }}:</span>
                    <span class="command-text">{{ item.command }}</span>
                    <el-button type="text" @click="reExecuteCommand(item)" size="small">重新执行</el-button>
                  </div>
                  <div class="command-output" v-if="item.output">
                    <pre>{{ item.output }}</pre>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </KoiCard>
      </el-col>
      
      <!-- 游戏进程窗口 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="12" :xl="12">
        <KoiCard header="游戏进程窗口" icon="Monitor">
          <template #headerBtn>
            <el-button type="primary" size="small" @click="refreshProcessList">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
          </template>
          <div v-loading="processLoading">
            <el-table v-if="processList.length > 0" :data="processList" style="width: 100%">
              <el-table-column prop="pid" label="PID" width="80" />
              <el-table-column prop="name" label="进程名称" />
              <el-table-column prop="cpu" label="CPU使用率">
                <template #default="scope">
                  {{ scope.row.cpu.toFixed(1) }}%
                </template>
              </el-table-column>
              <el-table-column prop="memory" label="内存使用">
                <template #default="scope">
                  {{ formatBytes(scope.row.memory) }}
                </template>
              </el-table-column>
              <el-table-column prop="uptime" label="运行时间">
                <template #default="scope">
                  {{ formatUptime(scope.row.uptime) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="120">
                <template #default="scope">
                  <el-button 
                    type="danger" 
                    size="small" 
                    @click="killProcess(scope.row.pid)"
                    :loading="killingProcess === scope.row.pid"
                  >
                    终止进程
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
            <el-empty v-else description="暂无游戏进程" />
          </div>
        </KoiCard>
      </el-col>
      
      <!-- 快捷操作面板 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="24" :xl="24">
        <KoiCard header="快捷操作" icon="Operation">
          <div class="quick-actions">
            <el-button type="primary" @click="navigateTo('/terraria/worlds')">
              <el-icon><Place /></el-icon>世界管理
            </el-button>
            <el-button type="primary" @click="navigateTo('/terraria/players')">
              <el-icon><User /></el-icon>玩家管理
            </el-button>
            <el-button type="primary" @click="navigateTo('/terraria/config')">
              <el-icon><Setting /></el-icon>服务器配置
            </el-button>
            <el-button type="primary" @click="navigateTo('/terraria/backups')">
              <el-icon><CopyDocument /></el-icon>备份管理
            </el-button>
            <el-button type="primary" @click="navigateTo('/terraria/plugins')">
              <el-icon><SetUp /></el-icon>插件管理
            </el-button>
            <el-button type="primary" @click="navigateTo('/terraria/logs')">
              <el-icon><Document /></el-icon>服务器日志
            </el-button>
            <el-button type="primary" @click="navigateTo('/terraria/console')">
              <el-icon><Monitor /></el-icon>服务器控制台
            </el-button>
            <el-button type="primary" @click="createBackupNow">
              <el-icon><Download /></el-icon>立即备份
            </el-button>
            <el-button type="warning" @click="showTshockUploadDialog">
              <el-icon><Upload /></el-icon>上传TShock服务器
            </el-button>
          </div>
        </KoiCard>
      </el-col>
      
      <!-- 服务器消息 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="24" :xl="24">
        <KoiCard header="发送服务器消息" icon="ChatDotRound">
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
        </KoiCard>
      </el-col>
      
      <!-- 服务器日志 -->
      <el-col :xs="24" :sm="24" :md="24" :lg="24" :xl="24">
        <KoiCard header="最近日志" icon="List">
          <template #headerBtn>
            <el-button type="primary" size="small" @click="getServerLogs">
              <el-icon><Refresh /></el-icon>
              刷新
            </el-button>
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
            <el-empty v-else description="暂无日志信息" />
          </div>
        </KoiCard>
      </el-col>
    </el-row>
    
    <!-- 版本信息 -->
    <div class="version-info">
      <span>泰拉瑞亚服务器管理面板</span>
      <span class="version-number">v1.0.6</span>
    </div>
    
    <!-- TShock上传对话框 -->
    <el-dialog
      v-model="tshockUploadDialogVisible"
      title="上传TShock服务器文件"
      width="500px"
      destroy-on-close
    >
      <div class="upload-dialog-content">
        <p>如果自动下载TShock失败，您可以手动下载并上传ZIP文件</p>
        
        <div class="download-links">
          <h4>下载链接:</h4>
          <p>
            <a href="https://github.com/Pryaxis/TShock/releases" target="_blank">
              GitHub下载TShock
            </a>
          </p>
          <p>选择适用于Linux的x64版本</p>
        </div>
        
        <el-upload
          class="tshock-uploader"
          action=""
          :http-request="uploadTshock"
          :limit="1"
          :show-file-list="true"
          :file-list="tshockFileList"
          accept=".zip"
          :on-exceed="handleExceed"
          :on-change="handleFileChange"
          :on-remove="handleFileRemove"
          :before-upload="beforeTshockUpload"
          drag
        >
          <el-icon class="el-icon--upload"><Upload /></el-icon>
          <div class="el-upload__text">
            将TShock服务器ZIP文件拖到此处或<em>点击上传</em>
          </div>
          <template #tip>
            <div class="el-upload__tip">
              只能上传ZIP文件，且大小不超过100MB
            </div>
          </template>
        </el-upload>
      </div>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="tshockUploadDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitTshockUpload" :loading="uploadLoading">
            上传并安装
          </el-button>
        </span>
      </template>
    </el-dialog>
    
    <!-- 房间信息编辑对话框 -->
    <el-dialog
      v-model="roomEditDialogVisible"
      title="编辑房间信息"
      width="500px"
    >
      <el-form :model="roomEditForm" label-width="100px">
        <el-form-item label="房间名称">
          <el-input v-model="roomEditForm.name" placeholder="请输入房间名称" />
        </el-form-item>
        <el-form-item label="房间密码">
          <el-input v-model="roomEditForm.password" placeholder="留空表示无密码" show-password />
        </el-form-item>
        <el-form-item label="最大人数">
          <el-input-number v-model="roomEditForm.maxPlayers" :min="1" :max="100" />
        </el-form-item>
        <el-form-item label="房间状态">
          <el-switch
            v-model="roomEditForm.isPublic"
            active-text="公开"
            inactive-text="私有"
          />
        </el-form-item>
        <el-form-item label="房间描述">
          <el-input 
            v-model="roomEditForm.description" 
            type="textarea" 
            placeholder="请输入房间描述"
            :rows="3"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="roomEditDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveRoomInfo" :loading="roomSaveLoading">
            保存
          </el-button>
        </span>
      </template>
    </el-dialog>
    
    <!-- Boss选择对话框 -->
    <el-dialog
      v-model="bossDialogVisible"
      title="选择要召唤的Boss"
      width="400px"
    >
      <el-form>
        <el-form-item>
          <el-select v-model="selectedBoss" placeholder="请选择Boss" style="width: 100%">
            <el-option
              v-for="boss in bossList"
              :key="boss.id"
              :label="boss.name"
              :value="boss.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="bossDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="spawnSelectedBoss" :loading="bossSpawnLoading">
            召唤
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts" name="TerrariaOverview">
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { User, Refresh, VideoPlay, VideoPause, RefreshRight, Place, Setting, CopyDocument, SetUp, Document, Download, Upload, Monitor, Sunny, Moon, Cloudy, Warning, DArrowRight, DArrowLeft, Edit } from '@element-plus/icons-vue';
import { 
  getServerStatus, 
  startServer, 
  stopServer, 
  restartServer, 
  sendServerMessage,
  createBackup,
  kickPlayer,
  banPlayer,
  uploadTShockFile,
  getSystemInformation,
  getRoomInformation,
  updateRoomInformation,
  executeServerCommand,
  executeSystemCommand,
  getProcessList,
  killGameProcess,
  setDayTime,
  setNightTime,
  toggleRain,
  togglePvP,
  saveWorldNow,
  spawnBoss
} from '@/api/system/terraria';
import { getServerLogs as fetchServerLogs } from '@/api/system/terraria';
import type { 
  TerrariaServerInfo, 
  TerrariaLogEntry, 
  SystemInfo, 
  RoomInfo, 
  ProcessInfo,
  CommandHistoryItem,
  BossInfo
} from '@/api/system/terraria/type';
import { ElMessage, ElMessageBox } from 'element-plus';
import KoiCard from '@/components/KoiCard/Index.vue';

// 路由
const router = useRouter();

// 状态数据
const serverStatus = ref<TerrariaServerInfo | null>(null);
const serverLogs = ref<TerrariaLogEntry[]>([]);
const statusLoading = ref(false);
const logsLoading = ref(false);
const controlLoading = ref(false);
const playerActionLoading = ref<number | null>(null);
const messageInput = ref('');
const messageLoading = ref(false);

// 系统信息
const systemInfo = ref<SystemInfo>({
  os: '',
  arch: '',
  cpuModel: '',
  cpuCores: 0,
  cpuUsage: 0,
  totalMem: 0,
  freeMem: 0,
  memUsage: 0,
  totalDisk: 0,
  freeDisk: 0,
  diskUsage: 0
});
const systemInfoLoading = ref(false);

// 房间信息
const roomInfo = ref<RoomInfo>({
  name: '',
  password: '',
  maxPlayers: 8,
  isPublic: true,
  createdAt: '',
  description: ''
});
const roomInfoLoading = ref(false);
const roomEditDialogVisible = ref(false);
const roomEditForm = ref<RoomInfo>({
  name: '',
  password: '',
  maxPlayers: 8,
  isPublic: true,
  createdAt: '',
  description: ''
});
const roomSaveLoading = ref(false);
const showPassword = ref(false);

// 命令执行
const commandInput = ref('');
const commandType = ref('server');
const commandLoading = ref(false);
const commandHistory = ref<CommandHistoryItem[]>([]);

// 游戏进程
const processList = ref<ProcessInfo[]>([]);
const processLoading = ref(false);
const killingProcess = ref<number | null>(null);

// Boss列表
const bossList = ref<BossInfo[]>([
  { id: 'eye_of_cthulhu', name: '克苏鲁之眼' },
  { id: 'eater_of_worlds', name: '世界吞噬者' },
  { id: 'brain_of_cthulhu', name: '克苏鲁之脑' },
  { id: 'queen_bee', name: '蜂后' },
  { id: 'skeletron', name: '骷髅王' },
  { id: 'wall_of_flesh', name: '血肉之墙' },
  { id: 'destroyer', name: '毁灭者' },
  { id: 'twins', name: '双子魔眼' },
  { id: 'skeletron_prime', name: '机械骷髅王' },
  { id: 'plantera', name: '世纪之花' },
  { id: 'golem', name: '石巨人' },
  { id: 'duke_fishron', name: '猪鲨公爵' },
  { id: 'lunatic_cultist', name: '拜月教邪教徒' },
  { id: 'moon_lord', name: '月亮领主' }
]);
const bossDialogVisible = ref(false);
const selectedBoss = ref('');
const bossSpawnLoading = ref(false);

// 定时刷新
let refreshTimer: number | null = null;

// TShock上传相关
const tshockUploadDialogVisible = ref(false);
const tshockFileList = ref<any[]>([]);
const uploadLoading = ref(false);
const uploadFile = ref<File | null>(null);

// 获取服务器状态
const getServerStatusData = async () => {
  statusLoading.value = true;
  try {
    const res = await getServerStatus();
    serverStatus.value = res.data;
  } catch (error) {
    console.error('获取服务器状态失败:', error);
    ElMessage.error('获取服务器状态失败');
  } finally {
    statusLoading.value = false;
  }
};

// 获取系统信息
const getSystemInfo = async () => {
  systemInfoLoading.value = true;
  try {
    const res = await getSystemInformation();
    systemInfo.value = res.data;
  } catch (error) {
    console.error('获取系统信息失败:', error);
    ElMessage.error('获取系统信息失败');
  } finally {
    systemInfoLoading.value = false;
  }
};

// 获取房间信息
const getRoomInfo = async () => {
  roomInfoLoading.value = true;
  try {
    const res = await getRoomInformation();
    roomInfo.value = res.data;
  } catch (error) {
    console.error('获取房间信息失败:', error);
    ElMessage.error('获取房间信息失败');
  } finally {
    roomInfoLoading.value = false;
  }
};

// 编辑房间信息
const editRoomInfo = () => {
  roomEditForm.value = { ...roomInfo.value };
  roomEditDialogVisible.value = true;
};

// 保存房间信息
const saveRoomInfo = async () => {
  roomSaveLoading.value = true;
  try {
    await updateRoomInformation(roomEditForm.value);
    ElMessage.success('房间信息已更新');
    roomEditDialogVisible.value = false;
    // 刷新房间信息
    await getRoomInfo();
  } catch (error) {
    console.error('更新房间信息失败:', error);
    ElMessage.error('更新房间信息失败');
  } finally {
    roomSaveLoading.value = false;
  }
};

// 执行命令
const executeCommand = async () => {
  if (!commandInput.value.trim()) {
    return;
  }
  
  commandLoading.value = true;
  try {
    let result;
    if (commandType.value === 'server') {
      result = await executeServerCommand(commandInput.value);
    } else {
      result = await executeSystemCommand(commandInput.value);
    }
    
    // 添加到命令历史
    commandHistory.value.unshift({
      type: commandType.value,
      command: commandInput.value,
      output: result.data,
      timestamp: new Date().toISOString()
    });
    
    // 保持历史记录不超过20条
    if (commandHistory.value.length > 20) {
      commandHistory.value.pop();
    }
    
    // 清空输入
    commandInput.value = '';
  } catch (error) {
    console.error('执行命令失败:', error);
    ElMessage.error('执行命令失败');
  } finally {
    commandLoading.value = false;
  }
};

// 重新执行历史命令
const reExecuteCommand = (item: CommandHistoryItem) => {
  commandInput.value = item.command;
  commandType.value = item.type;
  executeCommand();
};

// 清空命令历史
const clearCommandHistory = () => {
  commandHistory.value = [];
};

// 刷新进程列表
const refreshProcessList = async () => {
  processLoading.value = true;
  try {
    const res = await getProcessList();
    processList.value = res.data;
  } catch (error) {
    console.error('获取进程列表失败:', error);
    ElMessage.error('获取进程列表失败');
  } finally {
    processLoading.value = false;
  }
};

// 终止进程
const killProcess = async (pid: number) => {
  try {
    await ElMessageBox.confirm(
      '确定要终止该进程吗？',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    );
    
    killingProcess.value = pid;
    await killGameProcess(pid);
    ElMessage.success('进程已终止');
    refreshProcessList();
  } catch (error) {
    if (error !== 'cancel') {
      console.error('终止进程失败:', error);
      ElMessage.error('终止进程失败');
    }
  } finally {
    killingProcess.value = null;
  }
};

// 控制面板功能
const handleDayTime = async () => {
  try {
    await setDayTime();
    ElMessage.success('已设置为白天');
  } catch (error) {
    console.error('设置白天失败:', error);
    ElMessage.error('设置白天失败');
  }
};

const handleNightTime = async () => {
  try {
    await setNightTime();
    ElMessage.success('已设置为黑夜');
  } catch (error) {
    console.error('设置黑夜失败:', error);
    ElMessage.error('设置黑夜失败');
  }
};

const handleRain = async () => {
  try {
    await toggleRain(true);
    ElMessage.success('已开启雨天');
  } catch (error) {
    console.error('开启雨天失败:', error);
    ElMessage.error('开启雨天失败');
  }
};

const handleStopRain = async () => {
  try {
    await toggleRain(false);
    ElMessage.success('已停止雨天');
  } catch (error) {
    console.error('停止雨天失败:', error);
    ElMessage.error('停止雨天失败');
  }
};

const handlePvPOn = async () => {
  try {
    await togglePvP(true);
    ElMessage.success('已开启PvP');
  } catch (error) {
    console.error('开启PvP失败:', error);
    ElMessage.error('开启PvP失败');
  }
};

const handlePvPOff = async () => {
  try {
    await togglePvP(false);
    ElMessage.success('已关闭PvP');
  } catch (error) {
    console.error('关闭PvP失败:', error);
    ElMessage.error('关闭PvP失败');
  }
};

const handleSaveWorld = async () => {
  try {
    await saveWorldNow();
    ElMessage.success('世界已保存');
  } catch (error) {
    console.error('保存世界失败:', error);
    ElMessage.error('保存世界失败');
  }
};

const handleSpawnBoss = () => {
  selectedBoss.value = '';
  bossDialogVisible.value = true;
};

const spawnSelectedBoss = async () => {
  if (!selectedBoss.value) {
    ElMessage.warning('请选择要召唤的Boss');
    return;
  }
  
  bossSpawnLoading.value = true;
  try {
    await spawnBoss(selectedBoss.value);
    ElMessage.success('Boss已召唤');
    bossDialogVisible.value = false;
  } catch (error) {
    console.error('召唤Boss失败:', error);
    ElMessage.error('召唤Boss失败');
  } finally {
    bossSpawnLoading.value = false;
  }
};

// 获取服务器日志
const getServerLogs = async () => {
  logsLoading.value = true;
  try {
    const res = await fetchServerLogs(50);
    if (res?.data) {
      serverLogs.value = res.data;
    }
  } catch (error) {
    console.error('获取服务器日志失败:', error);
    ElMessage.error('获取服务器日志失败');
  } finally {
    logsLoading.value = false;
  }
};

// 启动服务器
const handleStartServer = async () => {
  controlLoading.value = true;
  try {
    await startServer();
    ElMessage.success('服务器正在启动');
    // 延迟刷新以便看到状态更改
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
    await ElMessageBox.confirm(
      '确定要停止服务器吗？这将断开所有玩家连接。',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    );
    
    controlLoading.value = true;
    await stopServer();
    ElMessage.success('服务器正在停止');
    // 延迟刷新以便看到状态更改
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
    await ElMessageBox.confirm(
      '确定要重启服务器吗？这将暂时断开所有玩家连接。',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    );
    
    controlLoading.value = true;
    await restartServer();
    ElMessage.success('服务器正在重启');
    // 延迟刷新以便看到状态更改
    setTimeout(() => {
      getServerStatusData();
    }, 2000);
  } catch (error) {
    if (error !== 'cancel') {
      console.error('重启服务器失败:', error);
      ElMessage.error('重启服务器失败');
    }
  } finally {
    controlLoading.value = false;
  }
};

// 发送服务器消息
const sendMessage = async () => {
  if (!messageInput.value.trim()) {
    return;
  }
  
  messageLoading.value = true;
  try {
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

// 踢出玩家
const handleKickPlayer = async (playerId: number) => {
  try {
    await ElMessageBox.confirm(
      '确定要踢出该玩家吗？',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    );
    
    playerActionLoading.value = playerId;
    await kickPlayer(playerId);
    ElMessage.success('玩家已被踢出');
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
const handleBanPlayer = async (playerId: number) => {
  try {
    await ElMessageBox.confirm(
      '确定要封禁该玩家吗？',
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    );
    
    playerActionLoading.value = playerId;
    await banPlayer(playerId);
    ElMessage.success('玩家已被封禁');
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

// 创建备份
const createBackupNow = async () => {
  try {
    await createBackup();
    ElMessage.success('备份已创建');
  } catch (error) {
    console.error('创建备份失败:', error);
    ElMessage.error('创建备份失败');
  }
};

// 显示TShock上传对话框
const showTshockUploadDialog = () => {
  tshockUploadDialogVisible.value = true;
};

// 处理文件超出限制
const handleExceed = () => {
  ElMessage.warning('只能上传一个文件');
};

// 处理文件变更
const handleFileChange = (file: any) => {
  uploadFile.value = file.raw;
};

// 处理文件移除
const handleFileRemove = () => {
  uploadFile.value = null;
};

// 上传前校验
const beforeTshockUpload = (file: File) => {
  const isZip = file.type === 'application/zip' || file.name.endsWith('.zip');
  if (!isZip) {
    ElMessage.error('只能上传ZIP文件');
    return false;
  }
  return true;
};

// 上传TShock文件
const uploadTshock = async (options: any) => {
  if (!uploadFile.value) {
    ElMessage.error('请选择文件');
    return;
  }
  
  uploadLoading.value = true;
  try {
    const formData = new FormData();
    formData.append('tshockFile', uploadFile.value);
    
    await uploadTShockFile(formData);
    ElMessage.success('TShock服务器文件已上传并解压');
    tshockUploadDialogVisible.value = false;
  } catch (error) {
    console.error('上传TShock文件失败:', error);
    ElMessage.error('上传TShock文件失败');
  } finally {
    uploadLoading.value = false;
  }
};

// 导航到其他页面
const navigateTo = (path: string) => {
  router.push(path);
};

// 格式化运行时间
const formatUptime = (seconds: number): string => {
  if (!seconds) return '0秒';
  
  const days = Math.floor(seconds / (24 * 60 * 60));
  const hours = Math.floor((seconds % (24 * 60 * 60)) / (60 * 60));
  const minutes = Math.floor((seconds % (60 * 60)) / 60);
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
  if (!bytes || bytes === 0) return '0 B';
  
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  
  return `${(bytes / Math.pow(1024, i)).toFixed(2)} ${sizes[i]}`;
};

// 获取状态类名
const getStatusClass = (status: string): string => {
  switch (status) {
    case 'running':
      return 'status-running';
    case 'starting':
      return 'status-starting';
    case 'stopping':
      return 'status-stopping';
    case 'stopped':
    default:
      return 'status-stopped';
  }
};

// 获取状态文本
const getStatusText = (status: string): string => {
  switch (status) {
    case 'running':
      return '运行中';
    case 'starting':
      return '正在启动';
    case 'stopping':
      return '正在停止';
    case 'stopped':
    default:
      return '已停止';
  }
};

// 获取生命值颜色
const getHealthColor = (health: number, maxHealth: number): string => {
  const percentage = (health / maxHealth) * 100;
  if (percentage <= 20) return '#F56C6C';
  if (percentage <= 50) return '#E6A23C';
  return '#67C23A';
};

// 获取日志级别类名
const getLogLevelClass = (level: string): string => {
  switch (level.toLowerCase()) {
    case 'error':
      return 'log-error';
    case 'warn':
    case 'warning':
      return 'log-warning';
    case 'info':
      return 'log-info';
    case 'debug':
      return 'log-debug';
    default:
      return '';
  }
};

// 初始化数据
onMounted(() => {
  getServerStatusData();
  getServerLogs();
  getSystemInfo();
  getRoomInfo();
  refreshProcessList();
  
  // 设置定时刷新
  refreshTimer = window.setInterval(() => {
    getServerStatusData();
  }, 10000); // 每10秒刷新一次
});

// 清理定时器
onUnmounted(() => {
  if (refreshTimer !== null) {
    clearInterval(refreshTimer);
  }
});
</script>

<style lang="scss" scoped>
.el-row {
  margin-bottom: 16px;
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
}

.status-starting {
  background-color: #E6A23C;
}

.status-stopping {
  background-color: #F56C6C;
}

.status-stopped {
  background-color: #909399;
}

.server-controls {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 20px;
}

.quick-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.message-area {
  margin-bottom: 10px;
}

.player-count {
  margin-right: 10px;
  font-weight: bold;
}

.logs-area {
  max-height: 300px;
  overflow-y: auto;
  border: 1px solid #EBEEF5;
  border-radius: 4px;
  padding: 10px;
}

.log-entries {
  font-family: monospace;
  font-size: 12px;
}

.log-entry {
  padding: 3px 0;
  border-bottom: 1px dashed #EBEEF5;
}

.log-timestamp {
  color: #909399;
  margin-right: 8px;
}

.log-level {
  font-weight: bold;
  margin-right: 8px;
}

.log-error {
  color: #F56C6C;
}

.log-warning {
  color: #E6A23C;
}

.log-info {
  color: #409EFF;
}

.log-debug {
  color: #909399;
}

.upload-dialog-content {
  margin-bottom: 20px;
}

.download-links {
  margin: 15px 0;
  padding: 10px;
  background-color: #f8f9fa;
  border-radius: 4px;
}

.tshock-uploader {
  margin-top: 20px;
}

.control-panel .el-row {
  margin-bottom: 10px;
}

.command-history {
  border: 1px solid #EBEEF5;
  border-radius: 4px;
  margin-top: 10px;
}

.command-history-header {
  display: flex;
  justify-content: space-between;
  padding: 8px 12px;
  background-color: #f8f9fa;
  border-bottom: 1px solid #EBEEF5;
}

.command-history-content {
  max-height: 300px;
  overflow-y: auto;
  padding: 8px 12px;
}

.command-history-item {
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px dashed #EBEEF5;
}

.command-input {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
}

.command-type {
  font-weight: bold;
  margin-right: 8px;
}

.command-text {
  flex: 1;
  font-family: monospace;
}

.command-output {
  background-color: #f8f9fa;
  padding: 8px;
  border-radius: 4px;
  font-family: monospace;
  font-size: 12px;
  white-space: pre-wrap;
}

pre {
  margin: 0;
  white-space: pre-wrap;
}

/* 版本信息样式 */
.version-info {
  text-align: center;
  margin-top: 20px;
  padding: 10px;
  color: #909399;
  font-size: 12px;
  border-top: 1px solid #EBEEF5;
}

.version-number {
  margin-left: 10px;
  font-weight: bold;
  color: #409EFF;
}
</style> 