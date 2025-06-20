<template>
  <div class="p-4px">
    <el-card class="rounded-md dark:bg-black" shadow="hover">
      <div class="flex flex-items-center" v-waterMarker="{ text: 'TERRARIA-ADMIN', textColor: '#D9D9D9' }">
        <img class="w-60px h-60px rounded-full select-none user-avatar" :src="avatar" alt="avatar" />
        <div class="p-l-20px">
          <div class="font-bold p-b-8px whitespace-nowrap">
            <span>泰拉瑞亚服务器管理系统</span>
          </div>
          <div class="font-bold whitespace-nowrap">欢迎使用泰拉瑞亚管理平台</div>
        </div>
      </div>
    </el-card>
    <KoiCard></KoiCard>
    <el-row :gutter="20" class="m-t-5px">
      <el-col :span="12" :lg="12" :md="12" :sm="24" :xs="24">
        <el-card class="rounded-md dark:bg-black" shadow="hover">
          <KoiLeftChart></KoiLeftChart>
        </el-card>
      </el-col>
      <el-col :span="12" :lg="12" :md="12" :sm="24" :xs="24">
        <el-card class="rounded-md dark:bg-black" shadow="hover">
          <KoiRightChart></KoiRightChart>
        </el-card>
      </el-col>
    </el-row>
    <el-row :gutter="20" class="m-t-5px">
      <el-col :span="24">
        <el-card class="rounded-md dark:bg-black" shadow="hover">
          <div class="p-4">
            <h3>系统说明</h3>
            <p>泰拉瑞亚管理平台允许您管理和监控多个泰拉瑞亚服务器实例。</p>
            <p>如果泰拉瑞亚管理平台运行在容器中，CPU、内存使用率将会根据为容器分配的资源进行计算。</p>
            <p>您可以通过本平台监控服务器性能、管理房间和世界、查看在线玩家等功能。</p>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { getDayText } from "@/utils/random";
import { koiNoticeSuccess } from "@/utils/koi";
import KoiCard from "./components/KoiCard.vue";
import KoiLeftChart from "./components/KoiLeftChart.vue";
import KoiRightChart from "./components/KoiRightChart.vue";
import { onMounted } from "vue";
onMounted(() => {
  // 时间问候语
  koiNoticeSuccess(getDayText(), "欢迎回来~");
});

// 头像
const avatar =
  "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fsafe-img.xhscdn.com%2Fbw1%2Fae90b4c7-98b6-4a47-b1b3-9ee8bc71acf6%3FimageView2%2F2%2Fw%2F1080%2Fformat%2Fjpg&refer=http%3A%2F%2Fsafe-img.xhscdn.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1692146441&t=6fca60f3a0d323869b81d8fb53b5dd1b";
</script>

<style lang="scss" scoped></style>
