<template>
  <div class="files-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>文件管理</span>
          <div class="header-actions">
            <el-breadcrumb separator="/">
              <el-breadcrumb-item v-for="(path, index) in pathParts" :key="index" @click="navigateTo(index)">
                {{ path || '根目录' }}
              </el-breadcrumb-item>
            </el-breadcrumb>
            <div class="action-buttons">
              <el-button type="primary" @click="refreshDirectory">刷新</el-button>
              <el-button type="success" @click="showCreateDialog('file')">新建文件</el-button>
              <el-button type="success" @click="showCreateDialog('directory')">新建目录</el-button>
              <el-button type="danger" @click="showDeleteSelectedDialog" :disabled="selectedFiles.length === 0">
                删除选中
              </el-button>
            </div>
          </div>
        </div>
      </template>
      
      <div v-loading="loading">
        <!-- 文件系统信息 -->
        <el-alert
          v-if="fileSystemInfo"
          type="info"
          :closable="false"
          show-icon
        >
          <div class="fs-info">
            <div v-for="(fs, index) in fileSystemInfo.filesystems" :key="index" class="fs-item">
              <span>{{ fs.mountpoint }}</span>
              <el-progress :percentage="fs.usagePercent" :color="getDiskColor(fs.usagePercent)" />
              <span>{{ formatBytes(fs.used) }} / {{ formatBytes(fs.size) }}</span>
            </div>
          </div>
        </el-alert>
        
        <!-- 文件列表 -->
        <el-table
          v-if="!loading && directoryContents.length > 0"
          :data="directoryContents"
          style="width: 100%"
          border
          stripe
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column label="名称" min-width="250">
            <template #default="scope">
              <div class="file-name-column">
                <el-icon v-if="scope.row.type === 'directory'"><Folder /></el-icon>
                <el-icon v-else-if="scope.row.type === 'file'"><Document /></el-icon>
                <el-icon v-else-if="scope.row.type === 'symlink'"><Link /></el-icon>
                <el-icon v-else><More /></el-icon>
                <span 
                  class="file-name"
                  :class="{ 'is-dir': scope.row.type === 'directory' }"
                  @click="handleFileClick(scope.row)"
                >
                  {{ scope.row.name }}
                </span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="size" label="大小" width="120">
            <template #default="scope">
              {{ scope.row.type === 'directory' ? '-' : formatBytes(scope.row.size) }}
            </template>
          </el-table-column>
          <el-table-column prop="permissions" label="权限" width="120" />
          <el-table-column prop="owner" label="所有者" width="120" />
          <el-table-column prop="group" label="用户组" width="120" />
          <el-table-column prop="modTime" label="修改时间" width="180" />
          <el-table-column label="操作" width="250">
            <template #default="scope">
              <el-button-group>
                <el-button 
                  v-if="scope.row.type === 'file'" 
                  size="small" 
                  type="primary" 
                  @click="handleViewFile(scope.row)"
                >
                  查看
                </el-button>
                <el-button 
                  v-if="scope.row.type === 'file'" 
                  size="small" 
                  type="warning" 
                  @click="handleEditFile(scope.row)"
                >
                  编辑
                </el-button>
                <el-button 
                  size="small" 
                  type="danger" 
                  @click="handleDeleteFile(scope.row)"
                >
                  删除
                </el-button>
              </el-button-group>
            </template>
          </el-table-column>
        </el-table>
        
        <el-empty v-else-if="!loading" description="当前目录为空" />
      </div>
    </el-card>
    
    <!-- 文件预览/编辑对话框 -->
    <el-dialog
      v-model="fileDialogVisible"
      :title="fileDialogTitle"
      width="60%"
      :close-on-click-modal="false"
      :destroy-on-close="true"
    >
      <div v-loading="fileLoading" class="file-dialog-content">
        <el-input
          v-if="fileDialogMode === 'edit'"
          v-model="fileContent"
          type="textarea"
          :rows="20"
          placeholder="文件内容"
        />
        <pre v-else-if="fileDialogMode === 'view'" class="file-preview">{{ fileContent }}</pre>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="fileDialogVisible = false">关闭</el-button>
          <el-button 
            v-if="fileDialogMode === 'edit'"
            type="primary" 
            @click="saveFileContent" 
            :loading="fileSaving"
          >
            保存
          </el-button>
        </span>
      </template>
    </el-dialog>
    
    <!-- 创建文件/目录对话框 -->
    <el-dialog
      v-model="createDialogVisible"
      :title="createDialogType === 'file' ? '新建文件' : '新建目录'"
      width="30%"
      :close-on-click-modal="false"
      :destroy-on-close="true"
    >
      <el-form :model="createForm" label-width="80px">
        <el-form-item label="名称" required>
          <el-input v-model="createForm.name" placeholder="请输入名称" />
        </el-form-item>
        <el-form-item v-if="createDialogType === 'file'" label="内容">
          <el-input
            v-model="createForm.content"
            type="textarea"
            :rows="10"
            placeholder="文件内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="createDialogVisible = false">取消</el-button>
          <el-button 
            type="primary" 
            @click="handleCreateFileOrDir" 
            :loading="createLoading"
          >
            创建
          </el-button>
        </span>
      </template>
    </el-dialog>
    
    <!-- 确认删除对话框 -->
    <el-dialog
      v-model="deleteDialogVisible"
      title="确认删除"
      width="30%"
      :close-on-click-modal="false"
    >
      <span>{{ deleteDialogMessage }}</span>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="deleteDialogVisible = false">取消</el-button>
          <el-button 
            type="danger" 
            @click="confirmDelete" 
            :loading="deleteLoading"
          >
            删除
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import { Folder, Document, Link, More } from '@element-plus/icons-vue';
import { 
  getFileSystemInfo, 
  getDirectoryContents, 
  readFile, 
  writeFile, 
  createFileOrDir, 
  deleteFileOrDir 
} from '@/api/system/linux';
import type { FileSystemInfo, DirectoryItem } from '@/api/system/linux/type';

// 数据状态
const loading = ref(false);
const currentPath = ref('/');
const directoryContents = ref<DirectoryItem[]>([]);
const fileSystemInfo = ref<FileSystemInfo | null>(null);
const selectedFiles = ref<DirectoryItem[]>([]);

// 文件预览/编辑对话框
const fileDialogVisible = ref(false);
const fileDialogTitle = ref('');
const fileDialogMode = ref<'view' | 'edit'>('view');
const fileContent = ref('');
const fileLoading = ref(false);
const fileSaving = ref(false);
const currentFile = ref<DirectoryItem | null>(null);

// 创建文件/目录对话框
const createDialogVisible = ref(false);
const createDialogType = ref<'file' | 'directory'>('file');
const createForm = ref({
  name: '',
  content: ''
});
const createLoading = ref(false);

// 删除对话框
const deleteDialogVisible = ref(false);
const deleteDialogMessage = ref('');
const deleteLoading = ref(false);
const deleteTarget = ref<{
  type: 'single' | 'multiple';
  items: DirectoryItem[];
}>({
  type: 'single',
  items: []
});

// 路径部分
const pathParts = computed(() => {
  if (currentPath.value === '/') return [''];
  return currentPath.value.split('/').filter(Boolean);
});

// 获取文件系统信息
const fetchFileSystemInfo = async () => {
  try {
    const res = await getFileSystemInfo();
    fileSystemInfo.value = res.data;
  } catch (error) {
    console.error('获取文件系统信息失败:', error);
    ElMessage.error('获取文件系统信息失败');
  }
};

// 获取目录内容
const fetchDirectoryContents = async (path: string = '/') => {
  try {
    loading.value = true;
    const res = await getDirectoryContents(path);
    directoryContents.value = res.data;
    currentPath.value = path;
  } catch (error) {
    console.error('获取目录内容失败:', error);
    ElMessage.error('获取目录内容失败');
  } finally {
    loading.value = false;
  }
};

// 刷新当前目录
const refreshDirectory = () => {
  fetchDirectoryContents(currentPath.value);
};

// 处理文件点击
const handleFileClick = (file: DirectoryItem) => {
  if (file.type === 'directory') {
    let newPath = currentPath.value;
    if (newPath.endsWith('/')) {
      newPath += file.name;
    } else {
      newPath += '/' + file.name;
    }
    fetchDirectoryContents(newPath);
  }
};

// 导航到指定路径层级
const navigateTo = (index: number) => {
  if (index === 0) {
    fetchDirectoryContents('/');
    return;
  }
  
  const parts = pathParts.value.slice(0, index + 1);
  const path = '/' + parts.join('/');
  fetchDirectoryContents(path);
};

// 处理查看文件
const handleViewFile = async (file: DirectoryItem) => {
  fileDialogMode.value = 'view';
  fileDialogTitle.value = `查看文件: ${file.name}`;
  fileContent.value = '';
  currentFile.value = file;
  fileDialogVisible.value = true;
  
  try {
    fileLoading.value = true;
    const res = await readFile(file.path);
    fileContent.value = res.data;
  } catch (error) {
    console.error('读取文件失败:', error);
    ElMessage.error('读取文件失败');
  } finally {
    fileLoading.value = false;
  }
};

// 处理编辑文件
const handleEditFile = async (file: DirectoryItem) => {
  fileDialogMode.value = 'edit';
  fileDialogTitle.value = `编辑文件: ${file.name}`;
  fileContent.value = '';
  currentFile.value = file;
  fileDialogVisible.value = true;
  
  try {
    fileLoading.value = true;
    const res = await readFile(file.path);
    fileContent.value = res.data;
  } catch (error) {
    console.error('读取文件失败:', error);
    ElMessage.error('读取文件失败');
  } finally {
    fileLoading.value = false;
  }
};

// 保存文件内容
const saveFileContent = async () => {
  if (!currentFile.value) return;
  
  try {
    fileSaving.value = true;
    await writeFile(currentFile.value.path, fileContent.value);
    ElMessage.success('文件保存成功');
    fileDialogVisible.value = false;
    refreshDirectory();
  } catch (error) {
    console.error('保存文件失败:', error);
    ElMessage.error('保存文件失败');
  } finally {
    fileSaving.value = false;
  }
};

// 显示创建文件/目录对话框
const showCreateDialog = (type: 'file' | 'directory') => {
  createDialogType.value = type;
  createForm.value = {
    name: '',
    content: ''
  };
  createDialogVisible.value = true;
};

// 处理创建文件/目录
const handleCreateFileOrDir = async () => {
  if (!createForm.value.name) {
    ElMessage.warning('名称不能为空');
    return;
  }
  
  const path = currentPath.value.endsWith('/')
    ? currentPath.value + createForm.value.name
    : currentPath.value + '/' + createForm.value.name;
  
  try {
    createLoading.value = true;
    await createFileOrDir(
      path, 
      createDialogType.value, 
      createDialogType.value === 'file' ? createForm.value.content : undefined
    );
    ElMessage.success(`${createDialogType.value === 'file' ? '文件' : '目录'}创建成功`);
    createDialogVisible.value = false;
    refreshDirectory();
  } catch (error) {
    console.error('创建失败:', error);
    ElMessage.error('创建失败');
  } finally {
    createLoading.value = false;
  }
};

// 处理删除文件/目录
const handleDeleteFile = (file: DirectoryItem) => {
  deleteTarget.value = {
    type: 'single',
    items: [file]
  };
  deleteDialogMessage.value = `确定要删除${file.type === 'directory' ? '目录' : '文件'} "${file.name}" 吗？`;
  deleteDialogVisible.value = true;
};

// 显示删除选中对话框
const showDeleteSelectedDialog = () => {
  if (selectedFiles.value.length === 0) return;
  
  deleteTarget.value = {
    type: 'multiple',
    items: [...selectedFiles.value]
  };
  deleteDialogMessage.value = `确定要删除选中的 ${selectedFiles.value.length} 个项目吗？`;
  deleteDialogVisible.value = true;
};

// 确认删除
const confirmDelete = async () => {
  try {
    deleteLoading.value = true;
    
    for (const item of deleteTarget.value.items) {
      await deleteFileOrDir(item.path, item.type === 'directory');
    }
    
    ElMessage.success('删除成功');
    deleteDialogVisible.value = false;
    refreshDirectory();
  } catch (error) {
    console.error('删除失败:', error);
    ElMessage.error('删除失败');
  } finally {
    deleteLoading.value = false;
  }
};

// 表格选择改变
const handleSelectionChange = (selection: DirectoryItem[]) => {
  selectedFiles.value = selection;
};

// 格式化字节单位
const formatBytes = (bytes: number): string => {
  if (bytes === 0) return '0 B';
  
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// 获取磁盘使用率颜色
const getDiskColor = (usage: number): string => {
  if (usage < 75) return '#67c23a';
  if (usage < 90) return '#e6a23c';
  return '#f56c6c';
};

// 生命周期钩子
onMounted(() => {
  fetchFileSystemInfo();
  fetchDirectoryContents('/');
});
</script>

<style lang="scss" scoped>
.files-container {
  padding: 16px;
}

.box-card {
  margin-bottom: 16px;
}

.card-header {
  display: flex;
  flex-direction: column;
  gap: 10px;
  
  .header-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    
    .action-buttons {
      display: flex;
      gap: 10px;
    }
  }
}

.fs-info {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  
  .fs-item {
    flex: 1;
    min-width: 200px;
    display: flex;
    flex-direction: column;
    gap: 5px;
  }
}

.file-name-column {
  display: flex;
  align-items: center;
  gap: 8px;
  
  .file-name {
    cursor: pointer;
    
    &.is-dir {
      color: #409eff;
      font-weight: bold;
    }
    
    &:hover {
      text-decoration: underline;
    }
  }
}

.file-dialog-content {
  min-height: 300px;
}

.file-preview {
  white-space: pre-wrap;
  font-family: monospace;
  background-color: #f8f8f8;
  padding: 10px;
  border-radius: 4px;
  max-height: 500px;
  overflow-y: auto;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style> 