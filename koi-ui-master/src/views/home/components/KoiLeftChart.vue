<template>
  <div>
    <h3 class="mb-4">系统资源监控</h3>
    <div class="chart-container">
      <div ref="refChart" style="height: 350px"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import * as echarts from "echarts";
import { ref, onMounted, onUnmounted } from "vue";
import axios from "axios";

interface SystemResources {
  cpu: {
    usage: number;
    cores: number;
    model: string;
  };
  memory: {
    total: number;
    used: number;
    free: number;
    usagePercent: number;
  };
  disk: {
    total: number;
    used: number;
    free: number;
    usagePercent: number;
  };
}

const refChart = ref();
const chartInstance = ref<echarts.ECharts | null>(null);
const systemData = ref<SystemResources>({
  cpu: {
    usage: 0,
    cores: 0,
    model: ""
  },
  memory: {
    total: 0,
    used: 0,
    free: 0,
    usagePercent: 0
  },
  disk: {
    total: 0,
    used: 0,
    free: 0,
    usagePercent: 0
  }
});

// 格式化数据显示
const formatSize = (bytes: number): string => {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

// 局部刷新定时器
const koiTimer = ref<number | undefined>(undefined);

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
  chartInstance.value?.dispose();
  chartInstance.value = null;
  // 清除局部刷新定时器
  if (koiTimer.value) {
    clearInterval(koiTimer.value);
    koiTimer.value = undefined;
  }
  // Echarts图表自适应销毁
  window.removeEventListener("resize", screenAdapter);
});

// 初始化加载图表
const initChart = () => {
  chartInstance.value = echarts.init(refChart.value);
  
  // 初始化显示三个仪表盘
  updateChart();

  // 鼠标移入停止定时器
  chartInstance.value.on("mouseover", () => {
    if (koiTimer.value) {
      clearInterval(koiTimer.value);
    }
  });

  // 鼠标移入启动定时器
  chartInstance.value.on("mouseout", () => {
    getDataTimer();
  });
};

// 获取接口
const getData = async () => {
  try {
    const response = await axios.get<SystemResources>("/api/linux/system/resources");
    systemData.value = response.data;
    updateChart();
  } catch (error) {
    console.error("获取系统资源数据失败:", error);
  }
};

const updateChart = () => {
  const { cpu, memory, disk } = systemData.value;
  
  const option = {
    tooltip: {
      formatter: function(params: any) {
        const { name, value } = params;
        if (name === 'CPU') {
          return `CPU使用率<br/>使用: ${value.toFixed(1)}%<br/>核心数: ${cpu.cores || "未知"}`;
        } else if (name === '内存') {
          const total = formatSize(memory.total);
          const used = formatSize(memory.used);
          return `内存使用率<br/>使用: ${value.toFixed(1)}%<br/>已用: ${used}<br/>总量: ${total}`;
        } else if (name === '磁盘') {
          const total = formatSize(disk.total);
          const used = formatSize(disk.used);
          return `磁盘使用率<br/>使用: ${value.toFixed(1)}%<br/>已用: ${used}<br/>总量: ${total}`;
        }
        return `${name}: ${value.toFixed(1)}%`;
      }
    },
    series: [
      {
        name: 'CPU使用率',
        type: 'gauge',
        center: ['25%', '50%'],
        radius: '75%',
        startAngle: 225,
        endAngle: -45,
        min: 0,
        max: 100,
        progress: {
          show: true
        },
        detail: {
          fontSize: 20,
          offsetCenter: [0, '30%'],
          valueAnimation: true,
          formatter: function(value: number) {
            return value.toFixed(1) + '%';
          },
          color: 'auto'
        },
        data: [{
          value: cpu.usage || 0,
          name: 'CPU'
        }],
        axisLine: {
          lineStyle: {
            width: 20,
            color: [
              [0.3, '#67C23A'],
              [0.7, '#409EFF'],
              [1, '#F56C6C']
            ]
          }
        },
        pointer: {
          icon: 'path://M12.8,0.7l12,40.1H0.7L12.8,0.7z',
          length: '12%',
          width: 10,
          offsetCenter: [0, '-60%'],
          itemStyle: {
            color: 'auto'
          }
        },
        axisTick: {
          length: 3,
          lineStyle: {
            color: 'auto',
            width: 1
          }
        },
        splitLine: {
          length: 5,
          lineStyle: {
            color: 'auto',
            width: 2
          }
        },
        axisLabel: {
          color: '#999',
          fontSize: 10,
          distance: -20
        },
        title: {
          offsetCenter: [0, '-20%'],
          color: '#999',
          fontSize: 14
        }
      },
      {
        name: '内存使用率',
        type: 'gauge',
        center: ['50%', '50%'],
        radius: '75%',
        startAngle: 225,
        endAngle: -45,
        min: 0,
        max: 100,
        progress: {
          show: true
        },
        detail: {
          fontSize: 20,
          offsetCenter: [0, '30%'],
          valueAnimation: true,
          formatter: function(value: number) {
            return value.toFixed(1) + '%';
          },
          color: 'auto'
        },
        data: [{
          value: memory.usagePercent || 0,
          name: '内存'
        }],
        axisLine: {
          lineStyle: {
            width: 20,
            color: [
              [0.3, '#67C23A'],
              [0.7, '#409EFF'],
              [1, '#F56C6C']
            ]
          }
        },
        pointer: {
          icon: 'path://M12.8,0.7l12,40.1H0.7L12.8,0.7z',
          length: '12%',
          width: 10,
          offsetCenter: [0, '-60%'],
          itemStyle: {
            color: 'auto'
          }
        },
        axisTick: {
          length: 3,
          lineStyle: {
            color: 'auto',
            width: 1
          }
        },
        splitLine: {
          length: 5,
          lineStyle: {
            color: 'auto',
            width: 2
          }
        },
        axisLabel: {
          color: '#999',
          fontSize: 10,
          distance: -20
        },
        title: {
          offsetCenter: [0, '-20%'],
          color: '#999',
          fontSize: 14
        }
      },
      {
        name: '磁盘使用率',
        type: 'gauge',
        center: ['75%', '50%'],
        radius: '75%',
        startAngle: 225,
        endAngle: -45,
        min: 0,
        max: 100,
        progress: {
          show: true
        },
        detail: {
          fontSize: 20,
          offsetCenter: [0, '30%'],
          valueAnimation: true,
          formatter: function(value: number) {
            return value.toFixed(1) + '%';
          },
          color: 'auto'
        },
        data: [{
          value: disk.usagePercent || 0,
          name: '磁盘'
        }],
        axisLine: {
          lineStyle: {
            width: 20,
            color: [
              [0.3, '#67C23A'],
              [0.7, '#409EFF'],
              [1, '#F56C6C']
            ]
          }
        },
        pointer: {
          icon: 'path://M12.8,0.7l12,40.1H0.7L12.8,0.7z',
          length: '12%',
          width: 10,
          offsetCenter: [0, '-60%'],
          itemStyle: {
            color: 'auto'
          }
        },
        axisTick: {
          length: 3,
          lineStyle: {
            color: 'auto',
            width: 1
          }
        },
        splitLine: {
          length: 5,
          lineStyle: {
            color: 'auto',
            width: 2
          }
        },
        axisLabel: {
          color: '#999',
          fontSize: 10,
          distance: -20
        },
        title: {
          offsetCenter: [0, '-20%'],
          color: '#999',
          fontSize: 14
        }
      }
    ]
  };
  
  chartInstance.value?.setOption(option);
};

// 定时器
const getDataTimer = () => {
  koiTimer.value = window.setInterval(() => {
    getData();
  }, 5000) as unknown as number; // 每5秒更新一次
};

// 自适应大小函数
const screenAdapter = () => {
  // 手动的调用图表对象的resize 才能产生效果
  chartInstance.value?.resize();
};
</script>

<style lang="scss" scoped>
.chart-container {
  padding: 20px;
}
</style>
