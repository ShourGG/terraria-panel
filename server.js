const express = require('express');
const path = require('path');
const fs = require('fs');
const os = require('os');
const { exec, spawn } = require('child_process');
const cors = require('cors');
const multer = require('multer');

const app = express();
const PORT = process.env.PORT || 10788;

// 定义版本信息
const VERSION = {
  PLATFORM: "1.2.0",  // 平台版本号
  UI: "1.0.0",        // UI版本号
  BUILD_DATE: "2024-07-30"  // 构建日期
};
const AdmZip = require('adm-zip');

// 配置中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态文件目录
const publicPath = process.env.PUBLIC_PATH || path.join(__dirname, 'public');
console.log(`使用本地public目录: ${publicPath}`);
app.use(express.static(publicPath));

// 文件上传配置
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, 'uploads'));
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  }
});
const upload = multer({ storage: storage });

// 确保上传目录存在
if (!fs.existsSync(path.join(__dirname, 'uploads'))) {
  fs.mkdirSync(path.join(__dirname, 'uploads'), { recursive: true });
}

// 泰拉瑞亚服务器状态
let terrariaProcess = null;
let terrariaStatus = {
  status: 'stopped',
  players: 0,
  uptime: '00:00:00',
  startTime: null,
  type: 'vanilla', // vanilla, tmod, tshock
  currentWorld: '',
  logs: []
};

// 泰拉瑞亚服务器路径配置
const TERRARIA_BASE_PATH = path.join(__dirname, 'terraria');
const PATHS = {
  vanilla: {
    server: path.join(TERRARIA_BASE_PATH, 'server'),
    worlds: path.join(TERRARIA_BASE_PATH, 'Worlds'),
    version: path.join(TERRARIA_BASE_PATH, 'version.txt')
  },
  tmod: {
    server: path.join(TERRARIA_BASE_PATH, 'TMLserver'),
    worlds: path.join(TERRARIA_BASE_PATH, 'WorldsTML'),
    version: path.join(TERRARIA_BASE_PATH, 'TMLversion.txt'),
    mods: path.join(TERRARIA_BASE_PATH, 'Mods')
  },
  tshock: {
    server: path.join(TERRARIA_BASE_PATH, 'TSserver'),
    worlds: path.join(TERRARIA_BASE_PATH, 'WorldsTS'),
    version: path.join(TERRARIA_BASE_PATH, 'TSversion.txt'),
    plugins: path.join(TERRARIA_BASE_PATH, 'TSserver', 'ServerPlugins')
  }
};

// 日志中间件
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// 获取用户主目录
const homeDir = os.homedir();
const terrariaDir = path.join(homeDir, 'terrariaPanel', 'terraria');
const panelDir = path.join(homeDir, 'terrariaPanel', 'panel');

// 检查public目录是否存在
if (fs.existsSync(publicPath) && fs.existsSync(path.join(publicPath, 'index.html'))) {
  console.log('使用本地public目录:', publicPath);
  app.use(express.static(publicPath));
  
  // 修改页面标题和首页重定向
  app.get('/', (req, res) => {
    // 读取index.html文件
    let indexHtml = fs.readFileSync(path.join(publicPath, 'index.html'), 'utf8');
    
    // 修改标题为"泰拉瑞亚服务器管理面板"
    indexHtml = indexHtml.replace(/<title>.*?<\/title>/, '<title>泰拉瑞亚服务器管理面板</title>');
    
    // 添加脚本，将首页重定向到泰拉瑞亚管理页面
    const redirectScript = `
    <script>
      // 页面加载完成后执行
      window.addEventListener('DOMContentLoaded', function() {
        // 等待Vue路由初始化完成
        setTimeout(function() {
          // 如果当前路径是首页，重定向到泰拉瑞亚管理页面
          if (window.location.pathname === '/' || window.location.pathname === '/home/index') {
            // 查找泰拉瑞亚管理菜单并点击
            const terrariaMenu = document.querySelector('a[href*="/terraria"]');
            if (terrariaMenu) {
              terrariaMenu.click();
            } else {
              // 如果找不到菜单，直接通过路由跳转
              if (window.location.href.indexOf('/terraria') === -1) {
                window.location.href = '/terraria/overview';
              }
            }
            
            // 隐藏其他无关菜单
            setTimeout(function() {
              const menuItems = document.querySelectorAll('.el-menu-item, .el-sub-menu');
              menuItems.forEach(function(item) {
                const text = item.textContent || '';
                if (text.indexOf('泰拉瑞亚') === -1 && text.indexOf('首页') === -1) {
                  item.style.display = 'none';
                }
              });
            }, 500);
          }
        }, 1000);
      });
    </script>
    `;
    
    // 将脚本插入到head标签结束前
    indexHtml = indexHtml.replace('</head>', redirectScript + '</head>');
    
    res.send(indexHtml);
  });
} else {
  console.log('本地public目录不存在或不完整，尝试使用面板安装目录下的public');
  const panelPublicPath = path.join(panelDir, 'public');
  if (fs.existsSync(panelPublicPath) && fs.existsSync(path.join(panelPublicPath, 'index.html'))) {
    console.log('使用面板安装目录下的public:', panelPublicPath);
    app.use(express.static(panelPublicPath));
    
    // 修改页面标题和首页重定向
    app.get('/', (req, res) => {
      // 读取index.html文件
      let indexHtml = fs.readFileSync(path.join(panelPublicPath, 'index.html'), 'utf8');
      
      // 修改标题为"泰拉瑞亚服务器管理面板"
      indexHtml = indexHtml.replace(/<title>.*?<\/title>/, '<title>泰拉瑞亚服务器管理面板</title>');
      
      // 添加脚本，将首页重定向到泰拉瑞亚管理页面
      const redirectScript = `
      <script>
        // 页面加载完成后执行
        window.addEventListener('DOMContentLoaded', function() {
          // 等待Vue路由初始化完成
          setTimeout(function() {
            // 如果当前路径是首页，重定向到泰拉瑞亚管理页面
            if (window.location.pathname === '/' || window.location.pathname === '/home/index') {
              // 查找泰拉瑞亚管理菜单并点击
              const terrariaMenu = document.querySelector('a[href*="/terraria"]');
              if (terrariaMenu) {
                terrariaMenu.click();
              } else {
                // 如果找不到菜单，直接通过路由跳转
                if (window.location.href.indexOf('/terraria') === -1) {
                  window.location.href = '/terraria/overview';
                }
              }
              
              // 隐藏其他无关菜单
              setTimeout(function() {
                const menuItems = document.querySelectorAll('.el-menu-item, .el-sub-menu');
                menuItems.forEach(function(item) {
                  const text = item.textContent || '';
                  if (text.indexOf('泰拉瑞亚') === -1 && text.indexOf('首页') === -1) {
                    item.style.display = 'none';
                  }
                });
              }, 500);
            }
          }, 1000);
        });
      </script>
      `;
      
      // 将脚本插入到head标签结束前
      indexHtml = indexHtml.replace('</head>', redirectScript + '</head>');
      
      res.send(indexHtml);
    });
  } else {
    console.warn('警告：找不到有效的前端文件目录');
  }
}

// 版本API路由
app.get('/api/version', (req, res) => {
  res.json({
    platform: VERSION.PLATFORM,
    ui: VERSION.UI,
    buildDate: VERSION.BUILD_DATE,
    port: PORT
  });
});

// 泰拉瑞亚服务器API路由
const terrariaRouter = express.Router();

// 上传和解压TShock服务器文件
terrariaRouter.post('/upload/tshock', upload.single('tshockFile'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ success: false, message: '未上传文件' });
  }

  try {
    console.log(`收到上传的文件: ${req.file.path}`);
    
    // 解压文件到泰拉瑞亚服务器目录
    const zip = new AdmZip(req.file.path);
    zip.extractAllTo(terrariaDir, true);
    
    // 设置TerrariaServer.exe的可执行权限
    if (fs.existsSync(path.join(terrariaDir, 'TerrariaServer.exe'))) {
      fs.chmodSync(path.join(terrariaDir, 'TerrariaServer.exe'), '755');
    }
    
    // 创建必要的目录结构
    const worldsDir = path.join(terrariaDir, 'worlds');
    const configDir = path.join(terrariaDir, 'config');
    const logsDir = path.join(terrariaDir, 'logs');
    
    if (!fs.existsSync(worldsDir)) {
      fs.mkdirSync(worldsDir, { recursive: true });
    }
    
    if (!fs.existsSync(configDir)) {
      fs.mkdirSync(configDir, { recursive: true });
    }
    
    if (!fs.existsSync(logsDir)) {
      fs.mkdirSync(logsDir, { recursive: true });
    }
    
    // 创建启动脚本
    const startScriptPath = path.join(terrariaDir, 'start-server.sh');
    const startScriptContent = `#!/bin/bash
cd "$(dirname "$0")"
mono --server --gc=sgen -O=all TerrariaServer.exe -configpath ./config -worldpath ./worlds -logpath ./logs "$@"
`;
    
    fs.writeFileSync(startScriptPath, startScriptContent);
    fs.chmodSync(startScriptPath, '755');
    
    // 删除上传的文件
    fs.unlinkSync(req.file.path);
    
    res.json({
      success: true,
      message: 'TShock服务器文件已成功上传并解压'
    });
  } catch (error) {
    console.error('处理上传文件时出错:', error);
    res.status(500).json({
      success: false,
      message: `处理上传文件时出错: ${error.message}`
    });
  }
});

// 服务器状态变量
let startTime = 0;
let serverLogs = [];

// 启动服务器
terrariaRouter.post('/start', (req, res) => {
  if (terrariaProcess) {
    return res.json({ success: false, message: '服务器已在运行' });
  }
  
  try {
    // 准备启动参数
    const port = req.body.port || 7777;
    const maxPlayers = req.body.maxPlayers || 8;
    const worldPath = req.body.worldPath || '';
    
    let args = ['-port', port, '-maxplayers', maxPlayers];
    
    if (worldPath) {
      args.push('-world', worldPath);
    }
    
    // 启动服务器进程
    terrariaProcess = spawn('mono', ['TerrariaServer.exe', ...args], {
      cwd: terrariaDir,
      stdio: ['pipe', 'pipe', 'pipe']
    });
    
    // 更新状态
    terrariaStatus.status = 'starting';
    terrariaStatus.port = port;
    terrariaStatus.maxPlayers = maxPlayers;
    startTime = Date.now();
    
    // 处理输出
    terrariaProcess.stdout.on('data', (data) => {
      const logLine = data.toString().trim();
      serverLogs.push({ time: new Date().toISOString(), message: logLine });
      
      // 限制日志数量
      if (serverLogs.length > 1000) {
        serverLogs.shift();
      }
      
      // 检测服务器启动完成
      if (logLine.includes('Server started')) {
        terrariaStatus.status = 'running';
      }
      
      // 检测玩家加入
      if (logLine.match(/(.+) has joined/)) {
        const playerName = logLine.match(/(.+) has joined/)[1];
        if (!terrariaStatus.players.includes(playerName)) {
          terrariaStatus.players.push(playerName);
        }
      }
      
      // 检测玩家离开
      if (logLine.match(/(.+) has left/)) {
        const playerName = logLine.match(/(.+) has left/)[1];
        terrariaStatus.players = terrariaStatus.players.filter(p => p !== playerName);
      }
    });
    
    terrariaProcess.stderr.on('data', (data) => {
      serverLogs.push({ time: new Date().toISOString(), message: `[ERROR] ${data.toString().trim()}` });
    });
    
    terrariaProcess.on('close', (code) => {
      serverLogs.push({ time: new Date().toISOString(), message: `服务器已关闭，退出代码: ${code}` });
      terrariaProcess = null;
      terrariaStatus.status = 'stopped';
      terrariaStatus.players = [];
      terrariaStatus.uptime = '00:00:00';
    });
    
    res.json({ success: true, message: '服务器正在启动' });
  } catch (error) {
    console.error('启动服务器时出错:', error);
    res.status(500).json({
      success: false,
      message: `启动服务器时出错: ${error.message}`
    });
  }
});

// 停止服务器
terrariaRouter.post('/stop', (req, res) => {
  if (!terrariaProcess) {
    return res.json({ success: false, message: '服务器未运行' });
  }
  
  try {
    // 发送停止命令
    terrariaProcess.stdin.write('exit\n');
    
    // 设置超时，如果服务器没有正常关闭，则强制终止
    setTimeout(() => {
      if (terrariaProcess) {
        terrariaProcess.kill('SIGTERM');
        terrariaProcess = null;
        terrariaStatus.status = 'stopped';
        terrariaStatus.players = [];
      }
    }, 5000);
    
    res.json({ success: true, message: '正在停止服务器' });
  } catch (error) {
    console.error('停止服务器时出错:', error);
    res.status(500).json({
      success: false,
      message: `停止服务器时出错: ${error.message}`
    });
  }
});

// 获取服务器状态
terrariaRouter.get('/status', (req, res) => {
  // 更新运行时间
  if (terrariaStatus.status === 'running' && startTime > 0) {
    const uptime = Math.floor((Date.now() - startTime) / 1000);
    terrariaStatus.uptime = formatUptime(uptime);
  }
  
  // 模拟资源使用情况
  if (terrariaStatus.status === 'running') {
    terrariaStatus.cpuUsage = Math.random() * 10 + 5; // 5-15%
    terrariaStatus.memoryUsage = Math.random() * 200 + 300; // 300-500MB
  } else {
    terrariaStatus.cpuUsage = 0;
    terrariaStatus.memoryUsage = 0;
  }
  
  res.json(terrariaStatus);
});

// 获取服务器日志
terrariaRouter.get('/logs', (req, res) => {
  const limit = parseInt(req.query.limit) || 100;
  res.json(serverLogs.slice(-limit));
});

// 发送命令到服务器
terrariaRouter.post('/command', (req, res) => {
  if (!terrariaProcess) {
    return res.json({ success: false, message: '服务器未运行' });
  }
  
  const command = req.body.command;
  if (!command) {
    return res.json({ success: false, message: '命令不能为空' });
  }
  
  try {
    terrariaProcess.stdin.write(command + '\n');
    res.json({ success: true, message: '命令已发送' });
  } catch (error) {
    console.error('发送命令时出错:', error);
    res.status(500).json({
      success: false,
      message: `发送命令时出错: ${error.message}`
    });
  }
});

// Linux系统API路由
const linuxRouter = express.Router();

// 系统信息API
linuxRouter.get('/system/info', (req, res) => {
  if (process.platform !== 'linux') {
    return res.json({
      hostname: os.hostname(),
      kernel: `${os.type()} ${os.release()}`,
      osType: os.type(),
      osRelease: os.release(),
      uptime: os.uptime(),
      loadAvg: os.loadavg(),
      arch: os.arch(),
      cpuModel: "模拟数据 - CPU型号",
      cpuCores: os.cpus().length,
      totalMemory: os.totalmem(),
      freeMemory: os.freemem()
    });
  }

  exec('cat /proc/cpuinfo | grep "model name" | head -n 1', (error, stdout) => {
    const cpuModel = error ? "未知" : stdout.split(':')[1].trim();
    
    res.json({
      hostname: os.hostname(),
      kernel: `${os.type()} ${os.release()}`,
      osType: os.type(),
      osRelease: os.release(),
      uptime: os.uptime(),
      loadAvg: os.loadavg(),
      arch: os.arch(),
      cpuModel: cpuModel,
      cpuCores: os.cpus().length,
      totalMemory: os.totalmem(),
      freeMemory: os.freemem()
    });
  });
});

// 系统资源API
linuxRouter.get('/system/resources', (req, res) => {
  let promises = [];
  
  // CPU使用率计算
  const cpuPromise = new Promise((resolve) => {
    // 采样两次CPU信息来计算使用率
    const startMeasure = os.cpus();
    
    setTimeout(() => {
      const endMeasure = os.cpus();
      let idleDiff = 0;
      let totalDiff = 0;
      
      for (let i = 0; i < startMeasure.length; i++) {
        // 计算每个核心的空闲时间差值
        const startIdle = startMeasure[i].times.idle;
        const endIdle = endMeasure[i].times.idle;
        const idleDiffCore = endIdle - startIdle;
        
        // 计算每个核心的总时间差值
        const startTotal = Object.values(startMeasure[i].times).reduce((a, b) => a + b);
        const endTotal = Object.values(endMeasure[i].times).reduce((a, b) => a + b);
        const totalDiffCore = endTotal - startTotal;
        
        idleDiff += idleDiffCore;
        totalDiff += totalDiffCore;
      }
      
      // 计算CPU使用率
      const cpuUsage = 100 - Math.floor((idleDiff / totalDiff) * 100);
      resolve(cpuUsage);
    }, 100); // 100毫秒的采样间隔
  });
  
  promises.push(cpuPromise);
  
  // 磁盘使用信息
  const diskPromise = new Promise((resolve) => {
    if (process.platform === 'win32') {
      // Windows系统
      exec('wmic logicaldisk get size,freespace,caption', (error, stdout) => {
        if (error) {
          resolve({
            total: 100 * 1024 * 1024 * 1024,
            used: 60 * 1024 * 1024 * 1024,
            free: 40 * 1024 * 1024 * 1024,
            usagePercent: 60
          });
          return;
        }
        
        const lines = stdout.trim().split('\n').slice(1);
        let total = 0;
        let free = 0;
        
        lines.forEach(line => {
          const parts = line.trim().split(/\s+/);
          if (parts.length >= 3) {
            const size = parseInt(parts[1]);
            const freeSpace = parseInt(parts[0]);
            if (!isNaN(size) && !isNaN(freeSpace)) {
              total += size;
              free += freeSpace;
            }
          }
        });
        
        const used = total - free;
        const usagePercent = total > 0 ? Math.floor((used / total) * 100) : 0;
        
        resolve({
          total,
          used,
          free,
          usagePercent
        });
      });
    } else {
      // Linux/Unix系统
      exec('df -k / | tail -1', (error, stdout) => {
        if (error) {
          resolve({
            total: 100 * 1024 * 1024 * 1024,
            used: 60 * 1024 * 1024 * 1024,
            free: 40 * 1024 * 1024 * 1024,
            usagePercent: 60
          });
          return;
        }
        
        const parts = stdout.trim().split(/\s+/);
        const total = parseInt(parts[1]) * 1024;
        const used = parseInt(parts[2]) * 1024;
        const free = parseInt(parts[3]) * 1024;
        const usagePercent = Math.floor((used / total) * 100);
        
        resolve({
          total,
          used,
          free,
          usagePercent
        });
      });
    }
  });
  
  promises.push(diskPromise);
  
  // 获取网络信息
  const networkPromise = new Promise((resolve) => {
    const interfaces = os.networkInterfaces();
    const networkData = {
      interfaces: []
    };
    
    for (const [name, netInterface] of Object.entries(interfaces)) {
      // 只获取IPv4地址
      const ipv4 = netInterface.find(i => i.family === 'IPv4' || i.family === 4);
      if (ipv4) {
        networkData.interfaces.push({
          name,
          ip: ipv4.address,
          mac: ipv4.mac,
          // 无法直接获取网络流量，这些值需要持续监控才准确
          rxBytes: 0,
          txBytes: 0,
          rxPackets: 0,
          txPackets: 0
        });
      }
    }
    
    resolve(networkData);
  });
  
  promises.push(networkPromise);
  
  // 等待所有异步操作完成
  Promise.all(promises).then(([cpuUsage, diskInfo, networkInfo]) => {
    // 内存信息直接从os模块获取
    const totalMemory = os.totalmem();
    const freeMemory = os.freemem();
    const usedMemory = totalMemory - freeMemory;
    const memoryUsagePercent = Math.floor((usedMemory / totalMemory) * 100);
    
    // 返回所有系统资源信息
    res.json({
      cpu: {
        usage: cpuUsage,
        cores: os.cpus().length,
        model: os.cpus()[0].model
      },
      memory: {
        total: totalMemory,
        used: usedMemory,
        free: freeMemory,
        buffers: Math.floor(freeMemory * 0.2), // 仍然是估算值
        cached: Math.floor(freeMemory * 0.3), // 仍然是估算值
        usagePercent: memoryUsagePercent
      },
      swap: {
        total: 2 * 1024 * 1024 * 1024, // 仍使用模拟值
        used: 1 * 1024 * 1024 * 1024,  // 仍使用模拟值
        free: 1 * 1024 * 1024 * 1024,  // 仍使用模拟值
        usagePercent: 50 // 仍使用模拟值
      },
      disk: diskInfo,
      network: networkInfo
    });
  }).catch(error => {
    console.error("获取系统资源信息出错:", error);
    // 出错时返回默认值
    res.json({
      cpu: {
        usage: 10,
        cores: os.cpus().length,
        model: "未知"
      },
      memory: {
        total: os.totalmem(),
        used: os.totalmem() - os.freemem(),
        free: os.freemem(),
        buffers: Math.floor(os.freemem() * 0.2),
        cached: Math.floor(os.freemem() * 0.3),
        usagePercent: ((os.totalmem() - os.freemem()) / os.totalmem()) * 100
      },
      swap: {
        total: 2 * 1024 * 1024 * 1024,
        used: 1 * 1024 * 1024 * 1024,
        free: 1 * 1024 * 1024 * 1024,
        usagePercent: 50
      },
      disk: {
        total: 100 * 1024 * 1024 * 1024,
        used: 60 * 1024 * 1024 * 1024,
        free: 40 * 1024 * 1024 * 1024,
        usagePercent: 60
      },
      network: {
        interfaces: []
      }
    });
  });
});

// 使用API路由
app.use('/api/terraria', terrariaRouter);
app.use('/api/linux', linuxRouter);

// 添加路由重定向
app.get('/terraria', (req, res) => {
  res.redirect('/');
});

// 处理所有前端路由 - 支持Vue Router的history模式
app.use((req, res) => {
  if (req.path.startsWith('/api')) {
    return res.status(404).json({ error: 'API不存在' });
  }
  
  // 获取面板目录的路径
  const panelPublicPath = path.join(panelDir, 'public');
  
  // 根据使用的前端目录决定返回哪个index.html
  if (fs.existsSync(publicPath) && fs.existsSync(path.join(publicPath, 'index.html'))) {
    res.sendFile(path.join(publicPath, 'index.html'));
  } else if (fs.existsSync(panelPublicPath) && fs.existsSync(path.join(panelPublicPath, 'index.html'))) {
    res.sendFile(path.join(panelPublicPath, 'index.html'));
  } else {
    res.status(404).send('找不到前端文件');
  }
});

// 确保泰拉瑞亚目录存在
async function ensureDirectoriesExist() {
  try {
    // 创建基本目录结构
    await fs.promises.mkdir(TERRARIA_BASE_PATH, { recursive: true });
    
    // 创建服务器类型目录
    for (const type in PATHS) {
      await fs.promises.mkdir(PATHS[type].server, { recursive: true });
      await fs.promises.mkdir(PATHS[type].worlds, { recursive: true });
      
      // 创建版本文件（如果不存在）
      try {
        await fs.promises.access(PATHS[type].version);
      } catch (error) {
        // 设置默认版本
        let defaultVersion = '';
        switch (type) {
          case 'vanilla':
            defaultVersion = '1.4.4.9';
            break;
          case 'tmod':
            defaultVersion = '2023.11';
            break;
          case 'tshock':
            defaultVersion = '5.2.0';
            break;
        }
        await fs.promises.writeFile(PATHS[type].version, defaultVersion);
      }
    }

    // 创建特殊目录
    await fs.promises.mkdir(PATHS.tmod.mods, { recursive: true });
    await fs.promises.mkdir(PATHS.tshock.plugins, { recursive: true });
    
    // 创建空的banlist.txt（如果不存在）
    const banlistPath = path.join(TERRARIA_BASE_PATH, 'banlist.txt');
    try {
      await fs.promises.access(banlistPath);
    } catch (error) {
      await fs.promises.writeFile(banlistPath, '');
    }
    
    console.log('泰拉瑞亚服务器目录结构已创建');
  } catch (error) {
    console.error('创建目录结构失败:', error);
  }
}

// 启动泰拉瑞亚服务器
async function startTerrariaServer(type = 'vanilla', worldName = 'world') {
  if (terrariaProcess) {
    return { success: false, message: '服务器已在运行中' };
  }

  try {
    // 确保目录存在
    await ensureDirectoriesExist();
    
    // 获取服务器可执行文件路径
    const serverPath = PATHS[type].server;
    const worldsPath = PATHS[type].worlds;
    
    // 构建启动命令
    let command;
    let args = [];
    const worldFilePath = path.join(worldsPath, `${worldName}.wld`);

    switch (type) {
      case 'vanilla':
        command = path.join(serverPath, 'TerrariaServer');
        args = ['-world', worldFilePath, '-autocreate', '2'];
        break;
      case 'tmod':
        command = path.join(serverPath, 'tModLoaderServer');
        args = ['-world', worldFilePath, '-autocreate', '2'];
        break;
      case 'tshock':
        command = path.join(serverPath, 'TerrariaServer.exe');
        args = ['-world', worldFilePath, '-autocreate', '2'];
        break;
      default:
        return { success: false, message: '未知的服务器类型' };
    }

    // 启动服务器进程
    terrariaProcess = spawn(command, args);
    terrariaStatus.status = 'running';
    terrariaStatus.startTime = Date.now();
    terrariaStatus.type = type;
    terrariaStatus.currentWorld = worldName;
    terrariaStatus.logs = [];

    // 处理服务器输出
    terrariaProcess.stdout.on('data', (data) => {
      const log = data.toString().trim();
      terrariaStatus.logs.push({ time: new Date().toISOString(), message: log });
      
      // 如果日志太多，保留最近的1000条
      if (terrariaStatus.logs.length > 1000) {
        terrariaStatus.logs.shift();
      }
      
      // 检查在线玩家数
      if (log.includes('player(s) online')) {
        const match = log.match(/(\d+) player\(s\) online/);
        if (match && match[1]) {
          terrariaStatus.players = parseInt(match[1]);
        }
      }
      
      console.log(`[Terraria] ${log}`);
    });

    // 处理错误
    terrariaProcess.stderr.on('data', (data) => {
      const log = data.toString().trim();
      terrariaStatus.logs.push({ time: new Date().toISOString(), message: log, type: 'error' });
      console.error(`[Terraria Error] ${log}`);
    });

    // 处理进程关闭
    terrariaProcess.on('close', (code) => {
      console.log(`[Terraria] 服务器已关闭，退出码：${code}`);
      terrariaProcess = null;
      terrariaStatus.status = 'stopped';
      terrariaStatus.players = 0;
      terrariaStatus.uptime = '00:00:00';
    });

    // 开始定期更新运行时间
    startUptimeCounter();

    return { success: true, message: '服务器启动成功' };
  } catch (error) {
    console.error('启动服务器失败:', error);
    return { success: false, message: `启动服务器失败: ${error.message}` };
  }
}

// 停止泰拉瑞亚服务器
function stopTerrariaServer() {
  if (!terrariaProcess) {
    return { success: false, message: '服务器未在运行' };
  }

  try {
    // 发送保存命令
    terrariaProcess.stdin.write('save\n');
    
    // 给点时间保存
    setTimeout(() => {
      // 发送退出命令
      terrariaProcess.stdin.write('exit\n');
      
      // 如果是模组服务器可能需要特殊命令
      if (terrariaStatus.type === 'tmod') {
        terrariaProcess.stdin.write('退出\n');
      }
      
      // 给服务器一点时间来优雅退出
      setTimeout(() => {
        // 如果进程还在运行，强制终止
        if (terrariaProcess) {
          terrariaProcess.kill('SIGTERM');
          terrariaProcess = null;
          terrariaStatus.status = 'stopped';
          terrariaStatus.players = 0;
          terrariaStatus.uptime = '00:00:00';
        }
      }, 5000);
    }, 2000);

    return { success: true, message: '服务器正在停止' };
  } catch (error) {
    console.error('停止服务器失败:', error);
    return { success: false, message: `停止服务器失败: ${error.message}` };
  }
}

// 定期更新运行时间
function startUptimeCounter() {
  const uptimeInterval = setInterval(() => {
    if (terrariaProcess && terrariaStatus.startTime) {
      const uptime = Date.now() - terrariaStatus.startTime;
      const hours = Math.floor(uptime / 3600000);
      const minutes = Math.floor((uptime % 3600000) / 60000);
      const seconds = Math.floor((uptime % 60000) / 1000);
      
      terrariaStatus.uptime = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    } else {
      clearInterval(uptimeInterval);
    }
  }, 1000);
}

// 格式化运行时间
function formatUptime(seconds) {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;
  
  return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
}

// 获取世界列表
async function getWorldsList(type = 'all') {
  try {
    const worlds = [];
    
    // 根据类型获取世界
    const typesToSearch = type === 'all' ? ['vanilla', 'tmod', 'tshock'] : [type];
    
    for (const serverType of typesToSearch) {
      const worldsPath = PATHS[serverType].worlds;
      
      try {
        // 读取世界目录
        const files = await fs.promises.readdir(worldsPath);
        
        // 筛选出.wld文件
        const worldFiles = files.filter(file => file.endsWith('.wld'));
        
        // 获取每个世界的信息
        for (const worldFile of worldFiles) {
          const filePath = path.join(worldsPath, worldFile);
          const stats = await fs.promises.stat(filePath);
          
          worlds.push({
            name: path.basename(worldFile, '.wld'),
            type: serverType,
            size: formatFileSize(stats.size),
            lastModified: stats.mtime.toISOString(),
            path: filePath
          });
        }
      } catch (error) {
        console.error(`读取${serverType}世界目录失败:`, error);
      }
    }
    
    return worlds;
  } catch (error) {
    console.error('获取世界列表失败:', error);
    return [];
  }
}

// 获取模组列表
async function getModsList() {
  try {
    const modsPath = PATHS.tmod.mods;
    const files = await fs.promises.readdir(modsPath);
    
    // 筛选出.tmod文件
    const modFiles = files.filter(file => file.endsWith('.tmod'));
    
    // 获取每个模组的信息
    const mods = [];
    for (const modFile of modFiles) {
      const filePath = path.join(modsPath, modFile);
      const stats = await fs.promises.stat(filePath);
      
      // 目前我们无法从.tmod文件中提取更多信息，所以只提供基本信息
      mods.push({
        name: path.basename(modFile, '.tmod'),
        version: 'Unknown', // 无法从文件名确定版本
        author: 'Unknown',  // 无法从文件名确定作者
        enabled: true,      // 默认启用
        size: formatFileSize(stats.size),
        lastModified: stats.mtime.toISOString(),
        path: filePath
      });
    }
    
    return mods;
  } catch (error) {
    console.error('获取模组列表失败:', error);
    return [];
  }
}

// 工具函数：格式化文件大小
function formatFileSize(bytes) {
  if (bytes === 0) return '0 B';
  
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  
  return parseFloat((bytes / Math.pow(1024, i)).toFixed(2)) + ' ' + sizes[i];
}

// API路由：泰拉瑞亚服务器管理
app.get('/api/terraria/status', (req, res) => {
  res.json(terrariaStatus);
});

app.post('/api/terraria/start', async (req, res) => {
  const type = req.body.type || 'vanilla';
  const worldName = req.body.worldName || 'world';
  
  const result = await startTerrariaServer(type, worldName);
  res.json(result);
});

app.post('/api/terraria/stop', (req, res) => {
  const result = stopTerrariaServer();
  res.json(result);
});

app.post('/api/terraria/restart', async (req, res) => {
  const type = terrariaStatus.type || 'vanilla';
  const worldName = terrariaStatus.currentWorld || 'world';
  
  // 先停止
  stopTerrariaServer();
  
  // 等待服务器完全停止
  setTimeout(async () => {
    // 然后重新启动
    const result = await startTerrariaServer(type, worldName);
    res.json(result);
  }, 8000);
});

app.post('/api/terraria/sendCommand', (req, res) => {
  if (!terrariaProcess) {
    return res.status(400).json({ success: false, message: '服务器未在运行' });
  }
  
  const command = req.body.command;
  if (!command) {
    return res.status(400).json({ success: false, message: '命令不能为空' });
  }
  
  try {
    terrariaProcess.stdin.write(`${command}\n`);
    res.json({ success: true, message: '命令已发送' });
  } catch (error) {
    res.status(500).json({ success: false, message: `发送命令失败: ${error.message}` });
  }
});

app.get('/api/terraria/worlds', async (req, res) => {
  const type = req.query.type || 'all';
  const worlds = await getWorldsList(type);
  res.json(worlds);
});

app.get('/api/terraria/mods', async (req, res) => {
  const mods = await getModsList();
  res.json(mods);
});

app.delete('/api/terraria/worlds/:name', async (req, res) => {
  const worldName = req.params.name;
  const type = req.query.type || 'vanilla';
  
  if (!worldName) {
    return res.status(400).json({ success: false, message: '世界名称不能为空' });
  }
  
  try {
    const worldPath = path.join(PATHS[type].worlds, `${worldName}.wld`);
    await fs.promises.unlink(worldPath);
    
    // 同时删除.twld文件（如果存在）
    try {
      await fs.promises.unlink(path.join(PATHS[type].worlds, `${worldName}.twld`));
    } catch (error) {
      // 如果.twld文件不存在，忽略错误
    }
    
    // 同时删除.bak文件（如果存在）
    try {
      await fs.promises.unlink(path.join(PATHS[type].worlds, `${worldName}.wld.bak`));
    } catch (error) {
      // 如果.bak文件不存在，忽略错误
    }
    
    res.json({ success: true, message: `世界 ${worldName} 已删除` });
  } catch (error) {
    res.status(500).json({ success: false, message: `删除世界失败: ${error.message}` });
  }
});

app.delete('/api/terraria/mods/:name', async (req, res) => {
  const modName = req.params.name;
  
  if (!modName) {
    return res.status(400).json({ success: false, message: '模组名称不能为空' });
  }
  
  try {
    const modPath = path.join(PATHS.tmod.mods, `${modName}.tmod`);
    await fs.promises.unlink(modPath);
    res.json({ success: true, message: `模组 ${modName} 已删除` });
  } catch (error) {
    res.status(500).json({ success: false, message: `删除模组失败: ${error.message}` });
  }
});

// 确保目录结构存在
ensureDirectoriesExist().catch(console.error);

// 启动服务器
app.listen(PORT, () => {
  console.log(`泰拉瑞亚服务器管理面板正在运行，端口: ${PORT}`);
});
