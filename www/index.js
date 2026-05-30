const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const HOME = process.cwd();
const NPM = path.join(HOME, 'node_modules', '.bin', 'npm');
const NPX = path.join(HOME, 'node_modules', '.bin', 'npx');
const OPENCODE = path.join(HOME, 'node_modules', '.bin', 'opencode');

function log(msg) {
  process.stdout.write('[iOpencode] ' + msg + '\n');
}

function ensurePackageJson() {
  const pkgPath = path.join(HOME, 'package.json');
  if (!fs.existsSync(pkgPath)) {
    fs.writeFileSync(pkgPath, JSON.stringify({
      name: 'iOpencode-workspace',
      version: '1.0.0',
      private: true
    }, null, 2));
  }
}

function installOpencode() {
  return new Promise((resolve, reject) => {
    log('Installing opencode...');
    const proc = spawn(NPM, ['install', 'opencode@latest', '--no-audit', '--no-fund'], {
      cwd: HOME,
      stdio: ['pipe', 'inherit', 'inherit'],
      env: {
        ...process.env,
        HOME,
        NPM_CONFIG_PREFIX: HOME,
        PATH: path.join(HOME, 'node_modules', '.bin') + ':' + process.env.PATH
      }
    });
    proc.on('close', code => {
      if (code === 0) {
        log('opencode installed successfully');
        resolve();
      } else {
        reject(new Error(`npm install exited with code ${code}`));
      }
    });
    proc.on('error', reject);
  });
}

function runOpencode() {
  return new Promise((resolve, reject) => {
    if (!fs.existsSync(OPENCODE)) {
      log('opencode binary not found, re-installing...');
      installOpencode().then(runOpencode).catch(reject);
      return;
    }
    log('Starting opencode...');
    const proc = spawn(OPENCODE, [], {
      cwd: HOME,
      stdio: ['inherit', 'inherit', 'inherit'],
      env: {
        ...process.env,
        HOME,
        TERM: 'xterm-256color',
        PATH: path.join(HOME, 'node_modules', '.bin') + ':' + process.env.PATH
      }
    });
    proc.on('close', code => {
      log(`opencode exited with code ${code}`);
      resolve();
    });
    proc.on('error', reject);
  });
}

async function main() {
  if (!fs.existsSync(NPM)) {
    log('npm not found! Node.js environment is incomplete.');
    process.exit(1);
  }
  ensurePackageJson();
  try {
    if (fs.existsSync(OPENCODE)) {
      await runOpencode();
    } else {
      await installOpencode();
      await runOpencode();
    }
  } catch (err) {
    log('Error: ' + err.message);
    process.exit(1);
  }
}

main();
