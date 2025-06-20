<template>
  <div class="error-container">
    <h1>403</h1>
    <p>禁止访问</p>
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
  color: #e67e22;
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