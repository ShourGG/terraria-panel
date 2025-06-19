<template>
  <div>
    <KoiCard header="世界管理" icon="Place">
      <template #headerBtn>
        <el-button type="primary" size="small" @click="refreshWorlds">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
        <el-button type="success" size="small" @click="showCreateWorldDialog">
          <el-icon><Plus /></el-icon>
          创建世界
        </el-button>
      </template>

      <div v-loading="loading">
        <el-table v-if="worlds.length" :data="worlds" style="width: 100%">
          <el-table-column prop="name" label="世界名称" min-width="150" />
          <el-table-column prop="size" label="大小" width="100">
            <template #default="scope">
              {{ getWorldSizeText(scope.row.size) }}
            </template>
          </el-table-column>
          <el-table-column prop="difficulty" label="难度" width="100">
            <template #default="scope">
              {{ getDifficultyText(scope.row.difficulty) }}
            </template>
          </el-table-column>
          <el-table-column prop="isSelected" label="状态" width="100">
            <template #default="scope">
              <el-tag v-if="scope.row.isSelected" type="success">当前选择</el-tag>
              <span v-else>-</span>
            </template>
          </el-table-column>
          <el-table-column prop="lastModified" label="最后修改" width="180" />
          <el-table-column prop="fileSizeBytes" label="文件大小" width="120">
            <template #default="scope">
              {{ formatBytes(scope.row.fileSizeBytes) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="220">
            <template #default="scope">
              <el-button 
                type="primary" 
                size="small" 
                :disabled="scope.row.isSelected" 
                @click="handleSelectWorld(scope.row)"
                :loading="actionLoading === scope.row.path"
              >
                选择
              </el-button>
              <el-button 
                type="danger" 
                size="small" 
                :disabled="scope.row.isSelected" 
                @click="handleDeleteWorld(scope.row)"
                :loading="actionLoading === scope.row.path"
              >
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>
        <el-empty v-else description="暂无世界文件" />
      </div>
    </KoiCard>

    <!-- 创建世界对话框 -->
    <el-dialog
      v-model="createWorldDialogVisible"
      title="创建新世界"
      width="500px"
      destroy-on-close
    >
      <el-form :model="worldForm" label-width="100px" :rules="worldFormRules" ref="worldFormRef">
        <el-form-item label="世界名称" prop="name">
          <el-input v-model="worldForm.name" placeholder="请输入世界名称" />
        </el-form-item>
        <el-form-item label="世界大小" prop="size">
          <el-select v-model="worldForm.size" placeholder="请选择世界大小" style="width: 100%">
            <el-option label="小型" value="small" />
            <el-option label="中型" value="medium" />
            <el-option label="大型" value="large" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度" prop="difficulty">
          <el-select v-model="worldForm.difficulty" placeholder="请选择难度" style="width: 100%">
            <el-option label="普通" value="normal" />
            <el-option label="专家" value="expert" />
            <el-option label="大师" value="master" />
            <el-option label="旅行" value="journey" />
          </el-select>
        </el-form-item>
        <el-form-item label="种子" prop="seed">
          <el-input v-model="worldForm.seed" placeholder="可选，留空则随机生成" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="createWorldDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleCreateWorld" :loading="createLoading">
            创建
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts" name="TerrariaWorlds">
import { ref, onMounted } from 'vue';
import { getWorldList, selectWorld, deleteWorld, createWorld } from '@/api/system/terraria';
import type { TerrariaWorld } from '@/api/system/terraria/type';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Refresh, Plus } from '@element-plus/icons-vue';
import type { FormInstance } from 'element-plus';
import KoiCard from '@/components/KoiCard/Index.vue';

// 数据定义
const worlds = ref<TerrariaWorld[]>([]);
const loading = ref(false);
const actionLoading = ref<string | null>(null);
const createWorldDialogVisible = ref(false);
const createLoading = ref(false);
const worldFormRef = ref<FormInstance>();
const worldForm = ref({
  name: '',
  size: 'medium',
  difficulty: 'normal',
  seed: ''
});

// 表单验证规则
const worldFormRules = {
  name: [
    { required: true, message: '请输入世界名称', trigger: 'blur' },
    { min: 1, max: 20, message: '长度在1到20个字符之间', trigger: 'blur' }
  ],
  size: [
    { required: true, message: '请选择世界大小', trigger: 'change' }
  ],
  difficulty: [
    { required: true, message: '请选择难度', trigger: 'change' }
  ]
};

// 获取世界列表
const fetchWorldList = async () => {
  loading.value = true;
  try {
    const res = await getWorldList();
    worlds.value = res.data;
  } catch (error) {
    console.error('获取世界列表失败:', error);
    ElMessage.error('获取世界列表失败');
  } finally {
    loading.value = false;
  }
};

// 刷新世界列表
const refreshWorlds = () => {
  fetchWorldList();
};

// 显示创建世界对话框
const showCreateWorldDialog = () => {
  createWorldDialogVisible.value = true;
};

// 处理创建世界
const handleCreateWorld = async () => {
  if (!worldFormRef.value) return;
  
  await worldFormRef.value.validate(async (valid) => {
    if (valid) {
      createLoading.value = true;
      try {
        await createWorld({
          name: worldForm.value.name,
          size: worldForm.value.size as 'small' | 'medium' | 'large',
          difficulty: worldForm.value.difficulty as 'normal' | 'expert' | 'master' | 'journey',
          seed: worldForm.value.seed || undefined
        });
        
        ElMessage.success('世界创建任务已提交，请稍后刷新查看结果');
        createWorldDialogVisible.value = false;
        
        // 重置表单
        worldForm.value = {
          name: '',
          size: 'medium',
          difficulty: 'normal',
          seed: ''
        };
        
        // 延迟后刷新列表
        setTimeout(() => {
          fetchWorldList();
        }, 5000);
      } catch (error) {
        console.error('创建世界失败:', error);
        ElMessage.error('创建世界失败');
      } finally {
        createLoading.value = false;
      }
    }
  });
};

// 选择世界
const handleSelectWorld = async (world: TerrariaWorld) => {
  try {
    actionLoading.value = world.path;
    await selectWorld(world.path);
    ElMessage.success(`已选择世界: ${world.name}`);
    fetchWorldList();
  } catch (error) {
    console.error('选择世界失败:', error);
    ElMessage.error('选择世界失败');
  } finally {
    actionLoading.value = null;
  }
};

// 删除世界
const handleDeleteWorld = async (world: TerrariaWorld) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除世界"${world.name}"吗？该操作不可恢复！`,
      '警告',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    );
    
    actionLoading.value = world.path;
    await deleteWorld(world.path);
    ElMessage.success('世界已删除');
    fetchWorldList();
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除世界失败:', error);
      ElMessage.error('删除世界失败');
    }
  } finally {
    actionLoading.value = null;
  }
};

// 获取世界大小文本
const getWorldSizeText = (size: string) => {
  switch (size) {
    case 'small':
      return '小型';
    case 'medium':
      return '中型';
    case 'large':
      return '大型';
    default:
      return size;
  }
};

// 获取难度文本
const getDifficultyText = (difficulty: string) => {
  switch (difficulty) {
    case 'normal':
      return '普通';
    case 'expert':
      return '专家';
    case 'master':
      return '大师';
    case 'journey':
      return '旅行';
    default:
      return difficulty;
  }
};

// 格式化字节数
const formatBytes = (bytes: number) => {
  if (!bytes) return '0 B';
  
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  
  return parseFloat((bytes / Math.pow(1024, i)).toFixed(2)) + ' ' + sizes[i];
};

// 生命周期钩子
onMounted(() => {
  fetchWorldList();
});
</script>

<style lang="scss" scoped>
.el-table {
  margin-bottom: 20px;
}
</style> 