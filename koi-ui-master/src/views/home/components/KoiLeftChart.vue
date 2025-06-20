<template>
  <div ref="refChart" style="height: 350px"></div>
</template>

<script setup lang="ts">
import * as echarts from "echarts";
import { ref, onMounted, onUnmounted } from "vue";

const refChart = ref();
const chartInstance = ref();
const allData = ref([
  {
    name: "CPU使用率",
    value: 45
  },
  {
    name: "内存使用率",
    value: 65
  },
  {
    name: "磁盘使用率",
    value: 78
  },
  {
    name: "网络带宽使用率",
    value: 42
  }
]);
// 局部刷新定时器
const koiTimer = ref();

onMounted(() => {
  // 图表初始化
  initChart();
  // 获取接口数据
  getData();
  // 调用Echarts图表自适应方法
  screenAdapter();
  // Echarts图表自适应
  window.addEventListener("resize", screenAdapter);
  // 局部刷新定时器
  getDataTimer();
});

onUnmounted(() => {
  // 销毁Echarts图表
  chartInstance.value.dispose();
  chartInstance.value = null;
  // 清除局部刷新定时器
  clearInterval(koiTimer.value);
  koiTimer.value = null;
  // Echarts图表自适应销毁
  window.removeEventListener("resize", screenAdapter);
});

// 初始化加载图表
const initChart = () => {
  // 覆盖默认主题
  // echarts.registerTheme('myTheme', skin);
  chartInstance.value = echarts.init(refChart.value);
  // 初始化加载图标样式
  const initOption = {
    title: {
      text: "系统资源使用率",
      left: 0,
      top: 0,
      textStyle: {
        color: "#077EF8"
      },
      subtext: "如果泰拉瑞亚管理平台运行在容器中，指标将根据容器资源进行计算"
    },
    grid: {
      top: "25%",
      left: "0",
      right: "0",
      bottom: "0",
      containLabel: true
    },
    tooltip: {
      show: true,
      formatter: '{b}: {c}%'
    },
    xAxis: {
      type: "category"
    },
    yAxis: {
      type: "value",
      // 去掉背景横刻度线
      splitLine: { show: false },
      max: 100,
      axisLabel: {
        formatter: '{value}%'
      }
    },
    series: [
      {
        type: "bar",
        label: {
          color: "#077EF8", // 设置顶部数字颜色
          show: true, // 开启数字显示
          position: "top", // 在上方显示数字
          formatter: '{c}%'
        }
      }
    ]
  };
  // 图表初始化配置
  chartInstance.value?.setOption(initOption);

  // 鼠标移入停止定时器
  chartInstance.value.on("mouseover", () => {
    clearInterval(koiTimer.value);
  });

  // 鼠标移入启动定时器
  chartInstance.value.on("mouseout", () => {
    getDataTimer();
  });
};

// 获取接口
const getData = () => {
  // 模拟获取服务器的数据
  updateChart();
};

const updateChart = () => {
  const colorArr = [
    ["#0BA82C", "#4FF778"],
    ["#2E72BF", "#23E5E5"],
    ["#5052EE", "#AB6EE5"],
    ["hotpink", "lightsalmon"]
  ];
  
  // 处理图表需要的数据
  const namesArr = allData.value.map(item => {
    return item.name;
  });
  const valueArr = allData.value.map(item => {
    return item.value;
  });

  const dataOption = {
    xAxis: { data: namesArr },
    series: [
      {
        data: valueArr,
        itemStyle: {
          label: {
            show: true,
            position: "top",
            formatter: '{c}%'
          },
          // 颜色样式部分
          // 柱状图颜色渐变
          color: (arg: any) => {
            let targetColorArr: any = null;
            if (arg.value > 80) {
              targetColorArr = colorArr[3]; // 危险级别 - 红色
            } else if (arg.value > 60) {
              targetColorArr = colorArr[2]; // 警告级别 - 紫色
            } else if (arg.value > 40) {
              targetColorArr = colorArr[1]; // 正常级别 - 蓝色
            } else {
              targetColorArr = colorArr[0]; // 良好级别 - 绿色
            }
            return new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              {
                offset: 0,
                color: targetColorArr[0]
              },
              {
                offset: 1,
                color: targetColorArr[1]
              }
            ]);
          }
        }
      }
    ]
  };
  // 图表数据变化配置
  chartInstance.value?.setOption(dataOption);
};

// 定时器
const getDataTimer = () => {
  koiTimer.value = setInterval(() => {
    // 模拟实时数据更新
    allData.value.forEach(item => {
      // 随机波动值，但保持在合理范围内
      const fluctuation = Math.random() * 10 - 5;
      item.value = Math.max(5, Math.min(95, item.value + fluctuation));
    });
    updateChart();
  }, 3000);
};

// 自适应大小函数
const screenAdapter = () => {
  const titleFontSize = ref(Math.round(refChart.value?.offsetWidth / 50));
  const adapterOption = {
    title: {
      textStyle: {
        fontSize: titleFontSize.value
      },
      subtextStyle: {
        fontSize: Math.round(titleFontSize.value * 0.7)
      }
    },
    xAxis: {
      //  改变x轴字体颜色和大小
      axisLabel: {
        fontSize: Math.round(titleFontSize.value * 0.8)
      }
    },
    yAxis: {
      //  改变y轴字体颜色和大小
      axisLabel: {
        fontSize: Math.round(titleFontSize.value * 0.8)
      }
    },
    series: [
      {
        // 圆柱的宽度
        barWidth: Math.round(titleFontSize.value * 2),
        itemStyle: {
          label: {
            textStyle: {
              fontSize: Math.round(titleFontSize.value * 0.8)
            }
          }
        }
      }
    ]
  };
  // 图表自适应变化配置
  chartInstance.value?.setOption(adapterOption);
  // 手动的调用图表对象的resize 才能产生效果
  chartInstance.value.resize();
};
</script>

<style lang="ts" scoped></style>
