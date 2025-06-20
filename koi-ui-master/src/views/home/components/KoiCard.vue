<template>
  <el-row :gutter="20" class="m-t-5px">
    <!-- 注意：如果不进行操作数组，使用index当key没有问题，若是数组会用来增删改查则不能使用index当key。 -->
    <el-col :span="8" :lg="8" :md="12" :sm="12" :xs="24" v-for="(item, index) in cardList" :key="index + new Date().getTime()">
      <el-card class="rounded-md dark:bg-black" shadow="hover">
        <div class="flex justify-between">
          <span class="text-sm">{{ item.title1 }}</span>
          <el-tag :type="index == 0 ? 'primary' : index == 1 ? 'success' : 'warning'">{{
            item.unit
          }}</el-tag>
        </div>
        <div class="text-2xl"><CountTo :startVal="0" :endVal="item.value1" :duration="2000"></CountTo></div>
        <el-divider direction="horizontal" content-position="left"></el-divider>
        <div class="flex justify-between">
          <span class="text-sm">{{ item.title2 }}</span>
          <span><CountTo :startVal="0" :endVal="item.value2" :duration="2000"></CountTo></span>
        </div>
      </el-card>
    </el-col>
  </el-row>
</template>

<script setup lang="ts">
// @ts-ignore
import { CountTo } from "vue3-count-to";
import { reactive } from "vue";

const cardList = reactive([
  { title1: "在线房间数", unit: "个", value1: 3, title2: "最大房间容量", value2: 8 },
  { title1: "活跃世界数", unit: "个", value1: 5, title2: "世界大小", value2: 2400 },
  { title1: "在线玩家数", unit: "人", value1: 12, title2: "服务器运行时间", value2: 72 }
]);
</script>

<style lang="scss" scoped></style>
