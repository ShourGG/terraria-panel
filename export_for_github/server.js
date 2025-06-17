const express = require('express');
const path = require('path');
const fs = require('fs');
const os = require('os');
const { exec } = require('child_process');
const app = express();
const port = process.env.PORT || 80;

// 日志中间件
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// 静态文件服务 - 托管前端文件
app.use(express.static(path.join(__dirname, 'dist')));

// API中间件
app.use(express.json());

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

// 进程列表API
linuxRouter.get('/system/processes', (req, res) => {
  // 模拟进程数据
  const processes = [];
  
  for (let i = 1; i <= 20; i++) {
    processes.push({
      pid: 1000 + i,
      ppid: i > 5 ? 1000 + (i % 5) : 1,
      uid: 1000,
      user: i % 3 === 0 ? "root" : "user",
      cmd: i % 5 === 0 ? "nginx" : i % 3 === 0 ? "node server.js" : "bash",
      cpu: Math.random() * 5,
      memory: Math.random() * 10,
      state: ["R", "S", "Z", "D", "T"][Math.floor(Math.random() * 5)],
      startTime: new Date(Date.now() - Math.random() * 86400000 * 10).toISOString()
    });
  }
  
  res.json(processes);
});

// 结束进程API
linuxRouter.delete('/system/process/:pid', (req, res) => {
  const pid = req.params.pid;
  
  if (process.platform !== 'linux') {
    return res.json({ success: true, message: `模拟环境：已结束进程 ${pid}` });
  }
  
  exec(`kill ${pid}`, (error) => {
    if (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
    
    res.json({ success: true, message: `已结束进程 ${pid}` });
  });
});

// 服务列表API
linuxRouter.get('/services', (req, res) => {
  // 模拟服务数据
  const services = [
    { name: "nginx", status: "active", enabled: true, description: "Nginx HTTP Server" },
    { name: "mysql", status: "active", enabled: true, description: "MySQL Database Server" },
    { name: "ssh", status: "active", enabled: true, description: "OpenSSH Server" },
    { name: "cron", status: "active", enabled: true, description: "Regular background program processing daemon" },
    { name: "firewalld", status: "inactive", enabled: false, description: "firewalld - dynamic firewall daemon" }
  ];
  
  res.json(services);
});

// 控制服务API
linuxRouter.post('/service/:name/:action', (req, res) => {
  const { name, action } = req.params;
  
  if (!['start', 'stop', 'restart'].includes(action)) {
    return res.status(400).json({ success: false, message: "无效的操作" });
  }
  
  if (process.platform !== 'linux') {
    return res.json({ success: true, message: `模拟环境：已${action === 'start' ? '启动' : action === 'stop' ? '停止' : '重启'}服务 ${name}` });
  }
  
  exec(`systemctl ${action} ${name}`, (error) => {
    if (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
    
    res.json({ success: true, message: `已${action === 'start' ? '启动' : action === 'stop' ? '停止' : '重启'}服务 ${name}` });
  });
});

// 文件系统信息API
linuxRouter.get('/fs/info', (req, res) => {
  if (process.platform !== 'linux') {
    // 模拟文件系统数据
    return res.json({
      filesystems: [
        {
          filesystem: "/dev/sda1",
          type: "ext4",
          size: 50 * 1024 * 1024 * 1024,
          used: 20 * 1024 * 1024 * 1024,
          available: 30 * 1024 * 1024 * 1024,
          mountpoint: "/",
          usagePercent: 40
        },
        {
          filesystem: "/dev/sda2",
          type: "ext4",
          size: 500 * 1024 * 1024 * 1024,
          used: 300 * 1024 * 1024 * 1024,
          available: 200 * 1024 * 1024 * 1024,
          mountpoint: "/home",
          usagePercent: 60
        }
      ]
    });
  }
  
  exec('df -T -B1', (error, stdout) => {
    if (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
    
    const lines = stdout.trim().split('\n').slice(1);
    const filesystems = lines.map(line => {
      const parts = line.split(/\s+/);
      const size = parseInt(parts[3], 10);
      const used = parseInt(parts[4], 10);
      const available = parseInt(parts[5], 10);
      const usagePercent = Math.round((used / size) * 100);
      
      return {
        filesystem: parts[0],
        type: parts[1],
        size,
        used,
        available,
        mountpoint: parts[6],
        usagePercent
      };
    });
    
    res.json({ filesystems });
  });
});

// 目录内容API
linuxRouter.get('/fs/list', (req, res) => {
  const path = req.query.path || '/';
  
  if (process.platform !== 'linux') {
    // 模拟目录内容
    return res.json([
      { name: "file1.txt", path: `${path}/file1.txt`, type: "file", size: 1024, owner: "user", group: "user", permissions: "rw-r--r--", modTime: "2023-01-01T12:00:00Z" },
      { name: "file2.log", path: `${path}/file2.log`, type: "file", size: 2048, owner: "user", group: "user", permissions: "rw-r--r--", modTime: "2023-01-02T12:00:00Z" },
      { name: "folder1", path: `${path}/folder1`, type: "directory", size: 0, owner: "user", group: "user", permissions: "rwxr-xr-x", modTime: "2023-01-03T12:00:00Z" }
    ]);
  }
  
  fs.readdir(path, { withFileTypes: true }, (err, files) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    
    const promises = files.map(file => {
      return new Promise((resolve) => {
        const filePath = path.endsWith('/') ? `${path}${file.name}` : `${path}/${file.name}`;
        
        fs.stat(filePath, (err, stats) => {
          if (err) {
            return resolve({
              name: file.name,
              path: filePath,
              type: "unknown",
              size: 0,
              owner: "unknown",
              group: "unknown",
              permissions: "unknown",
              modTime: new Date().toISOString()
            });
          }
          
          let type = "other";
          if (stats.isFile()) type = "file";
          else if (stats.isDirectory()) type = "directory";
          else if (stats.isSymbolicLink()) type = "symlink";
          
          // 在Linux上可以使用ls命令获取更多信息
          exec(`ls -la "${filePath}" | awk '{print $1, $3, $4}'`, (error, stdout) => {
            let permissions = "unknown";
            let owner = "unknown";
            let group = "unknown";
            
            if (!error) {
              const parts = stdout.trim().split(/\s+/);
              permissions = parts[0];
              owner = parts[1];
              group = parts[2];
            }
            
            resolve({
              name: file.name,
              path: filePath,
              type,
              size: stats.size,
              owner,
              group,
              permissions,
              modTime: stats.mtime.toISOString()
            });
          });
        });
      });
    });
    
    Promise.all(promises).then(directoryContents => {
      res.json(directoryContents);
    });
  });
});

// 读取文件API
linuxRouter.get('/fs/read', (req, res) => {
  const path = req.query.path;
  
  if (!path) {
    return res.status(400).json({ success: false, message: "未提供文件路径" });
  }
  
  fs.readFile(path, 'utf8', (err, data) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    
    res.send(data);
  });
});

// 写入文件API
linuxRouter.post('/fs/write', (req, res) => {
  const { path, content } = req.body;
  
  if (!path) {
    return res.status(400).json({ success: false, message: "未提供文件路径" });
  }
  
  fs.writeFile(path, content || '', 'utf8', (err) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    
    res.json({ success: true, message: "文件写入成功" });
  });
});

// 创建文件/目录API
linuxRouter.post('/fs/create', (req, res) => {
  const { path, type, content } = req.body;
  
  if (!path || !type) {
    return res.status(400).json({ success: false, message: "未提供路径或类型" });
  }
  
  if (type === 'directory') {
    fs.mkdir(path, { recursive: true }, (err) => {
      if (err) {
        return res.status(500).json({ success: false, message: err.message });
      }
      
      res.json({ success: true, message: "目录创建成功" });
    });
  } else if (type === 'file') {
    fs.writeFile(path, content || '', 'utf8', (err) => {
      if (err) {
        return res.status(500).json({ success: false, message: err.message });
      }
      
      res.json({ success: true, message: "文件创建成功" });
    });
  } else {
    res.status(400).json({ success: false, message: "无效的类型" });
  }
});

// 删除文件/目录API
linuxRouter.delete('/fs/delete', (req, res) => {
  const { path, recursive } = req.body;
  
  if (!path) {
    return res.status(400).json({ success: false, message: "未提供路径" });
  }
  
  fs.stat(path, (err, stats) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    
    if (stats.isDirectory()) {
      if (recursive) {
        fs.rmdir(path, { recursive: true }, (err) => {
          if (err) {
            return res.status(500).json({ success: false, message: err.message });
          }
          
          res.json({ success: true, message: "目录删除成功" });
        });
      } else {
        fs.rmdir(path, (err) => {
          if (err) {
            return res.status(500).json({ success: false, message: err.message });
          }
          
          res.json({ success: true, message: "目录删除成功" });
        });
      }
    } else {
      fs.unlink(path, (err) => {
        if (err) {
          return res.status(500).json({ success: false, message: err.message });
        }
        
        res.json({ success: true, message: "文件删除成功" });
      });
    }
  });
});

// 执行命令API
linuxRouter.post('/command/execute', (req, res) => {
  const { command } = req.body;
  
  if (!command) {
    return res.status(400).json({ success: false, message: "未提供命令" });
  }
  
  // 安全检查，禁止某些危险命令
  const dangerousCommands = ['rm -rf /', 'mkfs', 'dd if=/dev/zero'];
  if (dangerousCommands.some(dc => command.includes(dc))) {
    return res.status(403).json({ success: false, message: "禁止执行危险命令" });
  }
  
  const startTime = Date.now();
  
  exec(command, { timeout: 30000 }, (error, stdout, stderr) => {
    const executionTime = Date.now() - startTime;
    
    res.json({
      stdout: stdout || '',
      stderr: stderr || '',
      exitCode: error ? error.code : 0,
      executionTime
    });
  });
});

// 注册Linux API路由
app.use('/api/linux', linuxRouter);

// 所有其他请求返回前端应用
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

// 启动服务器
app.listen(port, () => {
  console.log(`泰拉瑞亚管理面板服务器启动在端口 ${port}`);
  console.log(`访问地址: http://localhost:${port}`);
}); 