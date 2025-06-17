<template>
  <el-row class="min-h-screen">
    <el-col :lg="16" :md="12" :sm="0" :xs="0" class="bg-[--el-color-primary] flex items-center justify-center">
      <div>
        <el-image v-if="!isScreen" class="w-400px h-360px mb-50px" :src="bg" />
        <div class="font-bold text-3xl text-light-50 mb-6px text-center">
          欢迎登录 {{ settings.loginTitle || "KOI-ADMIN 管理平台" }}
        </div>
        <div class="text-gray-200 text-lg text-center">或许我们只是差点运气</div>
      </div>
      <!-- 备案号-->
      <div class="beianhao">
        <a class="text-light-50" href="https://beian.miit.gov.cn/" target="_blank">网站备案号：豫ICP备2022022094号-1</a>
      </div>
    </el-col>
    <el-col :lg="8" :md="12" :sm="24" :xs="24" class="dark:bg-#121212 bg-gray-100 flex items-center justify-center flex-col">
      <div class="flex items-center">
        <el-image class="rounded-full w-36px h-36px" :src="logo" />
        <div class="ml-6px font-bold text-xl">{{ settings.loginTitle || "KOI-ADMIN 管理平台" }}</div>
      </div>
      <div class="flex items-center space-x-3 text-gray-400 mt-16px mb-16px">
        <span class="h-1px w-16 bg-gray-300 inline-block"></span>
        <span class="text-center">账号密码登录</span>
        <span class="h-1px w-16 bg-gray-300 inline-block"></span>
      </div>
      <!-- 输入框盒子 -->
      <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules">
        <el-form-item prop="userName">
          <el-input type="text" placeholder="请输入用户名" :suffix-icon="User" v-model="loginForm.loginName" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input type="password" placeholder="请输入密码" show-password :suffix-icon="Lock" v-model="loginForm.password" />
        </el-form-item>
        <el-form-item prop="securityCode">
          <el-input
            type="text"
            placeholder="请输入验证码"
            :suffix-icon="Open"
            v-model="loginForm.securityCode"
            @keydown.enter="handleKoiLogin"
          ></el-input>
        </el-form-item>
        <el-form-item>
          <el-image class="w-100px h-30px" :src="loginForm.captchaPicture" @click="handleCaptcha" />
          <el-button text size="small" class="ml-6px" @click="handleCaptcha">
            <div class="text-gray-400 hover:text-#8B5CF6 select-none">看不清，换一张</div>
          </el-button>
        </el-form-item>
        <!-- 登录按钮 -->
        <el-form-item>
          <el-button type="primary" v-if="!loading" class="w-245px bg-[--el-color-primary]" round @click="handleKoiLogin"
            >登录</el-button
          >
          <el-button type="primary" v-if="loading" class="w-245px bg-[--el-color-primary]" round :loading="loading"
            >登录中</el-button
          >
        </el-form-item>
      </el-form>
    </el-col>
  </el-row>
</template>

<script lang="ts" setup>
import { User, Lock, Open } from "@element-plus/icons-vue";
// @ts-ignore
import { ref, reactive, onMounted, onUnmounted } from "vue";

import type { FormInstance, FormRules } from "element-plus";
import { koiMsgError } from "@/utils/koi.ts";
import { useRouter } from "vue-router";
// import { koiLogin, getCaptcha } from "@/api/system/login/index.ts";
import authLogin from "@/assets/json/authLogin.json";
import useUserStore from "@/stores/modules/user.ts";
import useKeepAliveStore from "@/stores/modules/keepAlive.ts";
import { HOME_URL } from "@/config/index.ts";
import { initDynamicRouter } from "@/routers/modules/dynamicRouter.ts";
import useTabsStore from "@/stores/modules/tabs.ts";
import { getAssets } from "@/utils/index.ts";
import settings from "@/settings";
/** 适配移动端开始 */
import { useScreenStore } from "@/hooks/screen/index.ts";
// 获取当前为[移动端、IPad、PC端]仓库，阔以使用 watchEffect(() => {}) 进行监听。
const { isScreen } = useScreenStore();
/** 适配移动端结束 */

const userStore = useUserStore();
const tabsStore = useTabsStore();
const keepAliveStore = useKeepAliveStore();
const router = useRouter();

/** 用户登录代码 */
const logo = getAssets("images/logo/logo.webp");
const bg = getAssets("images/login/bg.png");
const loginFormRef = ref<FormInstance>();
const loading = ref(false);

interface ILoginUser {
  loginName: string;
  password: string | number;
  securityCode: string | number;
  codeKey: string | number;
  captchaPicture: any;
}

const loginForm = reactive<ILoginUser>({
  loginName: "yuadmin",
  password: "123456",
  securityCode: "1234",
  codeKey: "",
  captchaPicture: ""
});

const loginRules = reactive<FormRules<ILoginUser>>({
  loginName: [{ required: true, message: "用户名不能为空", trigger: "blur" }],
  password: [{ required: true, message: "密码不能为空", trigger: "blur" }],
  securityCode: [{ required: true, message: "验证码不能为空", trigger: "blur" }]
});

/** 获取验证码 */
const handleCaptcha = async () => {
  // try {
  //   const res: any = await getCaptcha();
  //   loginForm.codeKey = res.data.codeKey;
  //   loginForm.captchaPicture = res.data.captchaPicture;
  // } catch (error) {
  //   console.log(error);
  //   koiMsgError("验证码获取失败🌻");
  // }
};

// const koiTimer = ref();
// // 验证码定时器
// const getCaptchaTimer = () => {
//   koiTimer.value = setInterval(() => {
//     // 执行刷新数据的方法
//     handleCaptcha();
//   }, 345 * 1000);
// };

// 进入页面加载管理员信息
onMounted(() => {
  // 获取验证码
  handleCaptcha();
  // 局部刷新定时器
  // getCaptchaTimer();
});

// onUnmounted(() => {
//   // 清除局部刷新定时器
//   clearInterval(koiTimer.value);
//   koiTimer.value = null;
// });

/** 登录 */
const handleKoiLogin = () => {
  if (!loginFormRef.value) return;
  (loginFormRef.value as any).validate(async (valid: any, fields: any) => {
    // @ts-ignore
    const loginName = loginForm.loginName;
    // @ts-ignore
    const password = loginForm.password;
    // @ts-ignore
    const securityCode = loginForm.securityCode;
    // @ts-ignore
    const codeKey = loginForm.codeKey;
    if (valid) {
      loading.value = true;
      try {
        // 1、执行登录接口
        // const res: any = await koiLogin({ loginName, password, codeKey, securityCode });
        // userStore.setToken(res.data.tokenValue);
        userStore.setToken(authLogin.data.tokenValue);
        // 2、添加动态路由 AND 用户按钮 AND 角色信息 AND 用户个人信息
        await initDynamicRouter();

        // 3、清空 tabs数据、keepAlive缓存数据
        tabsStore.setTab([]);
        keepAliveStore.setKeepAliveName([]);

        // 4、跳转到首页
        loading.value = false;
        router.push(HOME_URL);
      } catch (error) {
        // 等待1秒关闭loading
        let loadingTime = 1;
        setInterval(() => {
          loadingTime--;
          if (loadingTime === 0) {
            loading.value = false;
          }
        }, 1000);
      }
    } else {
      console.log("登录校验失败", fields);
      koiMsgError("校验失败，信息填写有误🌻");
    }
  });
};
</script>

<style lang="scss" scoped>
/** 备案号 */
.beianhao {
  position: absolute;
  bottom: 10px;
  left: auto;
  font-size: 12px;
  font-weight: bold;
}
</style>
