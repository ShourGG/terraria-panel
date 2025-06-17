<template>
  <div class="services-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>服务管理</span>
          <div class="header-actions">
            <el-input
              v-model="searchKeyword"
              placeholder="搜索服务名称或描述"
              clearable
              class="search-input"
              @input="handleSearch"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
            <el-button type="primary" @click="fetchServices">刷新</el-button>
          </div>
        </div>
      </template>
      
      <el-table
        v-loading="loading"
        :data="paginatedServices"
        style="width: 100%"
        border
        stripe
      >
        <el-table-column prop="name" label="服务名称" min-width="180" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="120">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="enabled" label="开机启动" width="120">
          <template #default="scope">
            <el-tag :type="scope.row.enabled ? 'success' : 'info'">
              {{ scope.row.enabled ? '是' : '否' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="250" show-overflow-tooltip />
        <el-table-column fixed="right" label="操作" width="250">
          <template #default="scope">
            <el-button-group>
              <el-button 
                size="small" 
                type="success" 
                :disabled="scope.row.status === 'active'"
                @click="handleServiceAction(scope.row, 'start')"
              >
                启动
              </el-button>
              <el-button 
                size="small" 
                type="warning" 
                :disabled="scope.row.status !== 'active'"
                @click="handleServiceAction(scope.row, 'stop')"
              >
                停止
              </el-button>
              <el-button 
                size="small" 
                type="primary" 
                @click="handleServiceAction(scope.row, 'restart')"
              >
                重启
              </el-button>
            </el-button-group>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="filteredServices.length"
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
          <el-button 
            type="primary" 
            @click="confirmOperation" 
            :loading="operationLoading"
          >
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
import { ElMessage } from 'element-plus';
import { getServiceList, controlService } from '@/api/system/linux';
import type { Service } from '@/api/system/linux/type';

// 数据状态
const loading = ref(false);
const services = ref<Service[]>([]);
const searchKeyword = ref('');
const currentPage = ref(1);
const pageSize = ref(20);

// 操作确认对话框
const dialogVisible = ref(false);
const dialogTitle = ref('');
const dialogMessage = ref('');
const operationLoading = ref(false);
const currentOperation = ref<{ 
  service: string; 
  action: 'start' | 'stop' | 'restart';
}>({ service: '', action: 'start' });

// 获取服务列表
const fetchServices = async () => {
  try {
    loading.value = true;
    const res = await getServiceList();
    services.value = res.data;
  } catch (error) {
    console.error('获取服务列表失败:', error);
    ElMessage.error('获取服务列表失败');
  } finally {
    loading.value = false;
  }
};

// 根据关键字筛选服务
const filteredServices = computed(() => {
  if (!searchKeyword.value) {
    return services.value;
  }
  
  const keyword = searchKeyword.value.toLowerCase();
  return services.value.filter(service => {
    return service.name.toLowerCase().includes(keyword) || 
           service.description.toLowerCase().includes(keyword);
  });
});

// 分页后的服务列表
const paginatedServices = computed(() => {
  const startIndex = (currentPage.value - 1) * pageSize.value;
  return filteredServices.value.slice(startIndex, startIndex + pageSize.value);
});

// 获取服务状态对应的标签类型
const getStatusType = (status: 'active' | 'inactive' | 'failed'): string => {
  switch (status) {
    case 'active': return 'success';
    case 'inactive': return 'info';
    case 'failed': return 'danger';
    default: return '';
  }
};

// 获取服务状态对应的文本
const getStatusText = (status: 'active' | 'inactive' | 'failed'): string => {
  switch (status) {
    case 'active': return '运行中';
    case 'inactive': return '已停止';
    case 'failed': return '失败';
    default: return '未知';
  }
};

// 处理服务操作
const handleServiceAction = (service: Service, action: 'start' | 'stop' | 'restart') => {
  const actionText = {
    start: '启动',
    stop: '停止',
    restart: '重启'
  }[action];
  
  dialogTitle.value = `${actionText}服务`;
  dialogMessage.value = `确定要${actionText}服务 "${service.name}" 吗？`;
  currentOperation.value = { service: service.name, action };
  dialogVisible.value = true;
};

// 确认操作
const confirmOperation = async () => {
  operationLoading.value = true;
  
  try {
    await controlService(
      currentOperation.value.service, 
      currentOperation.value.action
    );
    
    const actionText = {
      start: '启动',
      stop: '停止',
      restart: '重启'
    }[currentOperation.value.action];
    
    ElMessage.success(`服务 ${currentOperation.value.service} ${actionText}成功`);
    
    // 刷新服务列表
    await fetchServices();
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

// 页面加载时获取服务列表
onMounted(() => {
  fetchServices();
});
</script>

<style lang="scss" scoped>
.services-container {
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