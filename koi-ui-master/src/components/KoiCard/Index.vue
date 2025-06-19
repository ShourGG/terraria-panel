<template>
  <div class="koi-card">
    <div v-if="header || $slots.header" class="koi-card-header">
      <div class="koi-card-header-left">
        <el-icon v-if="icon" class="header-icon">
          <component :is="icon" />
        </el-icon>
        <slot name="header">{{ header }}</slot>
      </div>
      <div class="koi-card-header-right">
        <slot name="headerBtn"></slot>
      </div>
    </div>
    <div class="koi-card-body">
    <slot></slot>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps({
  header: {
    type: String,
    default: ''
  },
  icon: {
    type: [String, Object],
    default: ''
  }
});
</script>

<style lang="scss" scoped>
.koi-card {
  border-radius: 6px;
  border: 1px solid #e4e7ed;
  background-color: #fff;
  overflow: hidden;
  color: #303133;
  transition: all 0.3s;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;

  .koi-card-header {
    padding: 16px 20px;
    border-bottom: 1px solid #ebeef5;
    display: flex;
    justify-content: space-between;
    align-items: center;

    .koi-card-header-left {
      font-size: 16px;
      font-weight: 500;
      display: flex;
      align-items: center;

      .header-icon {
        margin-right: 8px;
        font-size: 18px;
      }
    }
  }

  .koi-card-body {
    padding: 20px;
    flex: 1;
  }

  &:hover {
    box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  }

  :deep(.el-table) {
    --el-table-border-color: #dcdfe6;
    --el-table-header-bg-color: #f5f7fa;
  }

  // 暗黑模式
  @at-root html.dark & {
    background-color: #1d1e1f;
    color: #cfd3dc;
    border-color: #414243;

    .koi-card-header {
      border-bottom-color: #414243;
    }
  }
}
</style>
