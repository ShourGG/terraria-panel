import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'
import { createRouter, createWebHistory } from 'vue-router'
import { layoutRouter, staticRouter, errorRouter } from './routers/modules/staticRouter'

import App from './App.vue'

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

// 创建路由
const router = createRouter({
  history: createWebHistory(),
  routes: [...layoutRouter, ...staticRouter, ...errorRouter]
})

const app = createApp(App)
app.use(ElementPlus)
app.use(pinia)
app.use(router)

app.mount('#app') 