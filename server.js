const express = require('express');
const path = require('path');
const fs = require('fs');
const os = require('os');
const { exec, spawn } = require('child_process');
const app = express();
const port = process.env.PORT || 10788;
const multer = require('multer');
const AdmZip = require('adm-zip');

// 创建上传目录
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// 配置Multer用于文件上传
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function(req, file, cb) {
    cb(null, `tshock-${Date.now()}-${file.originalname}`);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 100 * 1024 * 1024 }, // 限制为100MB
  fileFilter: function(req, file, cb) {
    // 只允许上传zip文件
    if (file.mimetype !== 'application/zip' && !file.originalname.endsWith('.zip')) {
      return cb(new Error('只允许上传ZIP文件!'));
    }
    cb(null, true);
  }
});

// 日志中间件
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// 静态文件服务 - 托管前端文件
const distPath = path.join(__dirname, 'dist');
app.use(express.static(distPath));

// API中间件
app.use(express.json());

// 获取用户主目录
const homeDir = os.homedir();
const terrariaDir = path.join(homeDir, 'terrariaPanel', 'terraria');

// 确保目录存在
if (!fs.existsSync(terrariaDir)) {
  fs.mkdirSync(terrariaDir, { recursive: true });
}

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
let terrariaProcess = null;
let serverStatus = {
  status: 'stopped',
  version: 'v1.4.4.9',
  worldName: '',
  players: [],
  maxPlayers: 8,
  uptime: 0,
  port: 7777,
  difficulty: 'normal',
  memoryUsage: 0,
  cpuUsage: 0
};
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
    serverStatus.status = 'starting';
    serverStatus.port = port;
    serverStatus.maxPlayers = maxPlayers;
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
        serverStatus.status = 'running';
      }
      
      // 检测玩家加入
      if (logLine.match(/(.+) has joined/)) {
        const playerName = logLine.match(/(.+) has joined/)[1];
        if (!serverStatus.players.includes(playerName)) {
          serverStatus.players.push(playerName);
        }
      }
      
      // 检测玩家离开
      if (logLine.match(/(.+) has left/)) {
        const playerName = logLine.match(/(.+) has left/)[1];
        serverStatus.players = serverStatus.players.filter(p => p !== playerName);
      }
    });
    
    terrariaProcess.stderr.on('data', (data) => {
      serverLogs.push({ time: new Date().toISOString(), message: `[ERROR] ${data.toString().trim()}` });
    });
    
    terrariaProcess.on('close', (code) => {
      serverLogs.push({ time: new Date().toISOString(), message: `服务器已关闭，退出代码: ${code}` });
      terrariaProcess = null;
      serverStatus.status = 'stopped';
      serverStatus.players = [];
      serverStatus.uptime = 0;
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
        serverStatus.status = 'stopped';
        serverStatus.players = [];
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
  if (serverStatus.status === 'running' && startTime > 0) {
    serverStatus.uptime = Math.floor((Date.now() - startTime) / 1000);
  }
  
  // 模拟资源使用情况
  if (serverStatus.status === 'running') {
    serverStatus.cpuUsage = Math.random() * 10 + 5; // 5-15%
    serverStatus.memoryUsage = Math.random() * 200 + 300; // 300-500MB
  } else {
    serverStatus.cpuUsage = 0;
    serverStatus.memoryUsage = 0;
  }
  
  res.json(serverStatus);
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
  const cpuUsage = Math.random() * 100;
  
  res.json({
    cpu: {
      usage: cpuUsage,
      temp: 45 + Math.floor(Math.random() * 15)
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
      used: Math.floor(Math.random() * 1024 * 1024 * 1024),
      free: 1024 * 1024 * 1024,
      usagePercent: Math.random() * 40
    },
    disk: {
      total: 100 * 1024 * 1024 * 1024,
      used: 60 * 1024 * 1024 * 1024,
      free: 40 * 1024 * 1024 * 1024,
      usagePercent: 60
    },
    network: {
      interfaces: [
        {
          name: "eth0",
          ip: "192.168.1.100",
          mac: "00:11:22:33:44:55",
          rxBytes: 1024 * 1024 * 10,
          txBytes: 1024 * 1024 * 5,
          rxPackets: 8000,
          txPackets: 5000
        }
      ]
    }
  });
});

// 使用API路由
app.use('/api/terraria', terrariaRouter);
app.use('/api/linux', linuxRouter);

// 处理404 - 将所有其他请求重定向到前端路由
app.use((req, res) => {
  if (req.path.startsWith('/api')) {
    return res.status(404).json({ error: 'API不存在' });
  }
  res.sendFile(path.join(distPath, 'index.html'));
});

// 启动服务器
app.listen(port, () => {
  console.log(`泰拉瑞亚服务器管理面板正在运行，端口: ${port}`);
});
