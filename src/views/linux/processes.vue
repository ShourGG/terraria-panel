<template>
  <div class="processes-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>进程管理</span>
          <div class="header-actions">
            <el-input
              v-model="searchKeyword"
              placeholder="搜索进程名称或PID"
              clearable
              class="search-input"
              @input="handleSearch"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
            <el-button type="primary" @click="fetchProcesses">刷新</el-button>
          </div>
        </div>
      </template>
      
      <el-table
        v-loading="loading"
        :data="filteredProcesses"
        style="width: 100%"
        border
        stripe
        :default-sort="{ prop: 'cpu', order: 'descending' }"
      >
        <el-table-column prop="pid" label="PID" sortable width="100" />
        <el-table-column prop="ppid" label="父PID" sortable width="100" />
        <el-table-column prop="user" label="用户" sortable width="120" />
        <el-table-column prop="cpu" label="CPU%" sortable width="100">
          <template #default="scope">
            <span :class="{ 'high-usage': scope.row.cpu > 50 }">{{ scope.row.cpu.toFixed(1) }}%</span>
          </template>
        </el-table-column>
        <el-table-column prop="memory" label="内存%" sortable width="100">
          <template #default="scope">
            <span :class="{ 'high-usage': scope.row.memory > 50 }">{{ scope.row.memory.toFixed(1) }}%</span>
          </template>
        </el-table-column>
        <el-table-column prop="state" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="getStateTagType(scope.row.state)">{{ scope.row.state }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="startTime" label="启动时间" sortable width="180" />
        <el-table-column prop="cmd" label="命令" show-overflow-tooltip />
        <el-table-column fixed="right" label="操作" width="180">
          <template #default="scope">
            <el-button size="small" type="danger" @click="handleKillProcess(scope.row)">结束进程</el-button>
            <el-button size="small" type="warning" @click="handleKillProcessTree(scope.row)">结束进程树</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination-container">
        <el-pagination
          v-model:currentPage="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="filteredProcesses.length"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
    
    <!-- 操作确认对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="30%"
      :close-on-click-modal="false"
    >
      <span>{{ dialogMessage }}</span>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="confirmOperation" :loading="operationLoading">
            确认
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { Search } from '@element-plus/icons-vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getProcessList, killProcess } from '@/api/system/linux';
import type { Process } from '@/api/system/linux/type';

// 数据状态
const loading = ref(false);
const processes = ref<Process[]>([]);
const searchKeyword = ref('');
const currentPage = ref(1);
const pageSize = ref(20);

// 操作确认对话框
const dialogVisible = ref(false);
const dialogTitle = ref('');
const dialogMessage = ref('');
const operationLoading = ref(false);
const currentOperation = ref<{ type: string; pid: number }>({ type: '', pid: 0 });

// 获取进程列表
const fetchProcesses = async () => {
  try {
    loading.value = true;
    const res = await getProcessList({});
    processes.value = res.data;
  } catch (error) {
    console.error('获取进程列表失败:', error);
    ElMessage.error('获取进程列表失败');
  } finally {
    loading.value = false;
  }
};

// 根据关键字筛选进程
const filteredProcesses = computed(() => {
  if (!searchKeyword.value) {
    return processes.value;
  }
  
  const keyword = searchKeyword.value.toLowerCase();
  return processes.value.filter(process => {
    return process.cmd.toLowerCase().includes(keyword) || 
           process.pid.toString().includes(keyword) ||
           process.user.toLowerCase().includes(keyword);
  });
});

// 获取进程状态对应的标签类型
const getStateTagType = (state: string): '' | 'success' | 'warning' | 'danger' | 'info' => {
  switch (state.toUpperCase()) {
    case 'R': return 'success'; // 运行中
    case 'S': return 'info';    // 休眠
    case 'D': return 'warning'; // 不可中断的休眠
    case 'Z': return 'danger';  // 僵尸进程
    case 'T': return 'warning'; // 已停止
    default: return '';
  }
};

// 处理结束进程
const handleKillProcess = (process: Process) => {
  dialogTitle.value = '结束进程';
  dialogMessage.value = `确定要结束进程 "${process.cmd}" (PID: ${process.pid}) 吗？`;
  currentOperation.value = { type: 'kill', pid: process.pid };
  dialogVisible.value = true;
};

// 处理结束进程树
const handleKillProcessTree = (process: Process) => {
  dialogTitle.value = '结束进程树';
  dialogMessage.value = `确定要结束进程 "${process.cmd}" (PID: ${process.pid}) 及其所有子进程吗？`;
  currentOperation.value = { type: 'killtree', pid: process.pid };
  dialogVisible.value = true;
};

// 确认操作
const confirmOperation = async () => {
  operationLoading.value = true;
  
  try {
    if (currentOperation.value.type === 'kill') {
      await killProcess(currentOperation.value.pid);
      ElMessage.success(`进程 ${currentOperation.value.pid} 已结束`);
    } else if (currentOperation.value.type === 'killtree') {
      // 假设后端有对应的API
      await killProcess(currentOperation.value.pid);
      ElMessage.success(`进程 ${currentOperation.value.pid} 及其子进程已结束`);
    }
    
    // 刷新进程列表
    await fetchProcesses();
  } catch (error) {
    console.error('操作失败:', error);
    ElMessage.error('操作失败');
  } finally {
    operationLoading.value = false;
    dialogVisible.value = false;
  }
};

// 处理搜索
const handleSearch = () => {
  currentPage.value = 1;
};

// 处理分页
const handleSizeChange = (val: number) => {
  pageSize.value = val;
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
};

// 页面加载时获取进程列表
onMounted(() => {
  fetchProcesses();
});
</script>

<style lang="scss" scoped>
.processes-container {
  padding: 16px;
}

.box-card {
  margin-bottom: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  .header-actions {
    display: flex;
    align-items: center;
    gap: 16px;
    
    .search-input {
      width: 300px;
    }
  }
}

.high-usage {
  color: #f56c6c;
  font-weight: bold;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 