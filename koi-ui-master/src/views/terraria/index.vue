<template>
  <div class="container">
    <el-card class="header-card">
      <template #header>
        <div class="card-header">
          <h2>泰拉瑞亚服务器管理面板</h2>
          <div class="info-bar">
            <div>作者：初澈er</div>
            <div>版本：3.2</div>
            <div>QQ群：177781647</div>
          </div>
        </div>
      </template>
      <el-row :gutter="20">
        <el-col :span="8">
          <el-card shadow="hover">
            <template #header>服务器状态</template>
            <div class="status-container">
              <div class="status-item">
                <span>状态：</span>
                <el-tag type="success">在线</el-tag>
              </div>
              <div class="status-item">
                <span>在线玩家：</span>
                <el-tag type="info">2/8</el-tag>
              </div>
              <div class="status-item">
                <span>运行时间：</span>
                <span>12小时35分钟</span>
              </div>
            </div>
            <div class="button-group">
              <el-button type="primary">启动服务器</el-button>
              <el-button type="danger">停止服务器</el-button>
              <el-button type="warning">重启服务器</el-button>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover">
            <template #header>服务器配置</template>
            <el-form label-position="left" label-width="100px">
              <el-form-item label="服务器名称">
                <el-input v-model="serverConfig.name" placeholder="输入服务器名称"></el-input>
              </el-form-item>
              <el-form-item label="最大人数">
                <el-input-number v-model="serverConfig.maxPlayers" :min="1" :max="16"></el-input-number>
              </el-form-item>
              <el-form-item label="端口">
                <el-input v-model="serverConfig.port" placeholder="输入服务器端口"></el-input>
              </el-form-item>
              <el-form-item label="难度">
                <el-select v-model="serverConfig.difficulty" placeholder="选择难度">
                  <el-option label="普通" value="0"></el-option>
                  <el-option label="专家" value="1"></el-option>
                  <el-option label="大师" value="2"></el-option>
                  <el-option label="旅途" value="3"></el-option>
                </el-select>
              </el-form-item>
              <el-button type="success">保存配置</el-button>
            </el-form>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover">
            <template #header>玩家管理</template>
            <el-table :data="players" style="width: 100%">
              <el-table-column prop="name" label="玩家名称"></el-table-column>
              <el-table-column prop="status" label="状态">
                <template #default="scope">
                  <el-tag :type="scope.row.status === '在线' ? 'success' : 'info'">
                    {{ scope.row.status }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="操作">
                <template #default>
                  <el-button size="small" type="danger">踢出</el-button>
                  <el-button size="small" type="warning">禁止</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </el-col>
      </el-row>
      
      <el-row :gutter="20" style="margin-top: 20px">
        <el-col :span="24">
          <el-card shadow="hover">
            <template #header>控制台</template>
            <div class="console-container">
              <div class="console-output">
                <p v-for="(log, index) in consoleLogs" :key="index">{{ log }}</p>
              </div>
              <div class="console-input">
                <el-input v-model="consoleCommand" placeholder="输入命令" clearable>
                  <template #append>
                    <el-button @click="executeCommand">执行</el-button>
                  </template>
                </el-input>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const serverConfig = ref({
  name: '初澈er的泰拉瑞亚服务器',
  maxPlayers: 8,
  port: '7777',
  difficulty: '1'
});

const players = ref([
  { name: '玩家1', status: '在线' },
  { name: '玩家2', status: '在线' },
  { name: '玩家3', status: '离线' },
  { name: '玩家4', status: '离线' }
]);

const consoleLogs = ref([
  '[系统] 服务器启动中...',
  '[系统] 加载世界...',
  '[系统] 服务器启动完成',
  '[玩家1] 已连接到服务器',
  '[玩家2] 已连接到服务器'
]);

const consoleCommand = ref('');

const executeCommand = () => {
  if (consoleCommand.value) {
    consoleLogs.value.push(`[管理员] 执行命令: ${consoleCommand.value}`);
    consoleCommand.value = '';
  }
};
</script>

<style scoped>
.container {
  padding: 20px;
}

.header-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.info-bar {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-top: 10px;
  color: #666;
  font-size: 14px;
}

.status-container {
  margin-bottom: 15px;
}

.status-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
}

.button-group {
  display: flex;
  justify-content: space-between;
  margin-top: 15px;
}

.console-container {
  height: 300px;
  display: flex;
  flex-direction: column;
}

.console-output {
  flex: 1;
  background: #1e1e1e;
  color: #f0f0f0;
  padding: 10px;
  border-radius: 4px;
  overflow-y: auto;
  margin-bottom: 10px;
  font-family: monospace;
  height: 240px;
}

.console-output p {
  margin: 5px 0;
}

.console-input {
  margin-top: auto;
}
</style>
