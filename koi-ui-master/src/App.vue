<template>
  <el-config-provider :locale="locale" :size="dimension">
    <router-view></router-view>
  </el-config-provider>
</template>

<script setup lang="ts">
import { onMounted, computed } from "vue";
import { useI18n } from "vue-i18n";
import { getBrowserLang } from "@/utils/index.ts";
import { useTheme } from "@/utils/theme.ts";
import en from "element-plus/es/locale/lang/en";
import zhCn from "element-plus/es/locale/lang/zh-cn";

import useGlobalStore from "@/stores/modules/global.ts";
const globalStore = useGlobalStore();

const dimension = computed(() => globalStore.dimension);
const { initThemeConfig } = useTheme();

// 初始化语言
const i18n = useI18n();
onMounted(() => {
  const language = globalStore.language ?? getBrowserLang();
  i18n.locale.value = language;
  globalStore.setGlobalState("language", language);
  console.log(
    `%c KOI-UI %c V1.0.0 `,
    "padding: 2px 1px; border-radius: 3px 0 0 3px; color: #fff; background: #6169FF; font-weight: bold;",
    "padding: 2px 1px; border-radius: 0 3px 3px 0; color: #fff; background: #42c02e; font-weight: bold;"
  );
});

// 语言配置
const locale = computed(() => {
  if (globalStore.language == "zh") return zhCn;
  if (globalStore.language == "en") return en;
  return getBrowserLang() == "zh" ? zhCn : en;
});

// 初始化主题配置
initThemeConfig();
</script>

<style scoped></style>
