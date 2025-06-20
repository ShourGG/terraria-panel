<template>
  <div ref="refChart" style="max-width: 800px; height: 350px"></div>
</template>

<script setup lang="ts">
import * as echarts from "echarts";
import { ref, onMounted, onUnmounted } from "vue";

const refChart = ref();
const chartInstance = ref();
const xChartData = ref();
const yChartData = ref();
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

const initChart = () => {
  chartInstance.value = echarts.init(refChart.value);
  const initOption = {
    title: {
      text: "世界玩家数量统计",
      top: "0%",
      textStyle: {
        color: "#077EF8"
      }
    },
    grid: {
      top: "12%",
      left: "6%",
      bottom: "6%",
      right: "0"
    },
    tooltip: {
      show: true,
      trigger: 'axis'
    },
    legend: {
      data: ["当前玩家数", "平均在线人数"],
      right: "5%"
    },
    xAxis: [
      {
        type: "category",
        axisPointer: {
          type: "shadow"
        }
      }
    ],
    yAxis: [
      {
        type: "value",
        // 去掉背景横刻度线
        splitLine: { show: false },
        name: "玩家数量",
        min: 0
      }
    ],
    series: [
      {
        name: "当前玩家数",
        type: "bar",
        tooltip: {
          valueFormatter: function (value: any) {
            return value + " 人";
          }
        }
      },
      {
        name: "平均在线人数",
        type: "line",
        tooltip: {
          valueFormatter: function (value: any) {
            return value + " 人";
          }
        },
        // 圆滑连接
        smooth: true,
        itemStyle: {
          color: "#00f2f1" // 线颜色
        }
      }
    ]
  };
  // 图表初始化配置
  chartInstance.value?.setOption(initOption);
};

const getData = () => {
  // 先进行置空
  xChartData.value = [];
  yChartData.value = [];
  
  // 模拟世界数据
  const worldsData = [
    { name: "泰拉主世界", current: 5, average: 4 },
    { name: "矿石世界", current: 3, average: 2 },
    { name: "Boss世界", current: 2, average: 3 },
    { name: "PVP竞技场", current: 2, average: 2 },
    { name: "生存挑战", current: 0, average: 1 }
  ];
  
  xChartData.value = worldsData.map(world => world.name);
  const currentData = worldsData.map(world => world.current);
  const averageData = worldsData.map(world => world.average);
  
  updateChart(currentData, averageData);
};

const updateChart = (currentData: number[], averageData: number[]) => {
  const colorArr = [
    ["#0BA82C", "#4FF778"],
    ["#2E72BF", "#23E5E5"],
    ["#5052EE", "#AB6EE5"],
    ["hotpink", "lightsalmon"]
  ];
  
  // 处理图表需要的数据
  const dataOption = {
    xAxis: {
      // x轴刻度文字
      data: xChartData.value
    },
    series: [
      {
        // 当前玩家数
        data: currentData,
        itemStyle: {
          //颜色样式部分
          label: {
            show: true, //开启数字显示
            position: "top", //在上方显示数字
            formatter: '{c} 人',
            textStyle: {
              //数值样式
              color: "#077EF8" //字体颜色
            }
          },
          //柱状图颜色渐变
          color: (arg: any) => {
            let targetColorArr = null;
            if (arg.value > 4) {
              targetColorArr = colorArr[0];
            } else if (arg.value > 2) {
              targetColorArr = colorArr[1];
            } else if (arg.value > 0) {
              targetColorArr = colorArr[2];
            } else {
              targetColorArr = colorArr[3];
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
      },
      {
        // 平均在线人数
        data: averageData
      }
    ]
  };
  
  // 图表数据变化配置
  chartInstance.value?.setOption(dataOption);
};

const screenAdapter = () => {
  const titleFontSize = ref(Math.round(refChart.value?.offsetWidth / 50));
  const adapterOption = {
    title: {
      textStyle: {
        fontSize: titleFontSize.value
      }
    },
    // 圆点分类标题
    legend: {
      textStyle: {
        fontSize: titleFontSize.value * 0.8
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
        barWidth: Math.round(titleFontSize.value * 1.8),
        itemStyle: {
          //颜色样式部分
          label: {
            textStyle: {
              fontSize: Math.round(titleFontSize.value * 0.8) //字体大小
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

// 定时器
const getDataTimer = () => {
  koiTimer.value = setInterval(() => {
    getData();
  }, 10000);
};
</script>

<style scoped></style>
