<template>
  <div class="error-container">
    <h1>404</h1>
    <p>页面不存在</p>
    <router-link to="/">返回首页</router-link>
  </div>
</template>

<style scoped>
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  text-align: center;
}

h1 {
  font-size: 8rem;
  margin: 0;
  color: #e74c3c;
}

p {
  font-size: 2rem;
  margin: 1rem 0 2rem;
}

a {
  color: #3498db;
  text-decoration: none;
  font-size: 1.2rem;
}

a:hover {
  text-decoration: underline;
}
</style> 