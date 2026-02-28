# -*- coding: utf-8 -*-
"""
GitHub 自动推送工具 - 本地服务器
提供 API 接口供网页调用，执行 Git 命令
"""

import os
import sys
import json
import subprocess
import threading
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import re

# 项目根目录
PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))

class GitAPIHandler(BaseHTTPRequestHandler):
    """处理 Git API 请求"""
    
    def log_message(self, format, *args):
        """自定义日志格式"""
        print(f"[{self.log_date_time_string()}] {format % args}")
    
    def send_json_response(self, data, status=200):
        """发送 JSON 响应"""
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode('utf-8'))
    
    def do_OPTIONS(self):
        """处理 CORS 预检请求"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def do_GET(self):
        """处理 GET 请求"""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        if path == '/api/status':
            self.handle_get_status()
        elif path == '/api/info':
            self.handle_get_info()
        elif path == '/':
            self.serve_html()
        else:
            self.send_error(404, 'Not Found')
    
    def do_POST(self):
        """处理 POST 请求"""
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        # 读取请求体
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8') if content_length > 0 else '{}'
        
        try:
            data = json.loads(body) if body else {}
        except json.JSONDecodeError:
            data = {}
        
        if path == '/api/push':
            self.handle_push(data)
        elif path == '/api/release':
            self.handle_release(data)
        else:
            self.send_error(404, 'Not Found')
    
    def serve_html(self):
        """返回 HTML 页面"""
        html_path = os.path.join(PROJECT_ROOT, 'git-push-tool.html')
        if os.path.exists(html_path):
            with open(html_path, 'r', encoding='utf-8') as f:
                html_content = f.read()
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(html_content.encode('utf-8'))
        else:
            self.send_error(404, 'HTML file not found')
    
    def run_git_command(self, command, cwd=None):
        """执行 Git 命令"""
        if cwd is None:
            cwd = PROJECT_ROOT
        
        try:
            result = subprocess.run(
                command,
                shell=True,
                cwd=cwd,
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='replace'
            )
            return {
                'success': result.returncode == 0,
                'stdout': result.stdout,
                'stderr': result.stderr,
                'returncode': result.returncode
            }
        except Exception as e:
            return {
                'success': False,
                'stdout': '',
                'stderr': str(e),
                'returncode': -1
            }
    
    def handle_get_info(self):
        """获取项目信息"""
        # 项目名称
        project_name = os.path.basename(PROJECT_ROOT)
        
        # 当前分支
        branch_result = self.run_git_command('git branch --show-current')
        branch = branch_result['stdout'].strip() if branch_result['success'] else 'unknown'
        
        # 远程仓库
        remote_result = self.run_git_command('git remote get-url origin')
        remote_url = remote_result['stdout'].strip() if remote_result['success'] else ''
        
        # 未提交更改
        status_result = self.run_git_command('git status --porcelain')
        changes = [line for line in status_result['stdout'].strip().split('\n') if line.strip()]
        change_count = len(changes)
        
        # 构建仓库 URL
        repo_url = ''
        if remote_url:
            repo_url = remote_url.replace('.git', '').replace('git@github.com:', 'https://github.com/')
        
        self.send_json_response({
            'success': True,
            'data': {
                'projectName': project_name,
                'branch': branch,
                'remoteUrl': remote_url,
                'repoUrl': repo_url,
                'changeCount': change_count,
                'hasRemote': bool(remote_url)
            }
        })
    
    def handle_get_status(self):
        """获取 Git 状态"""
        result = self.run_git_command('git status')
        self.send_json_response({
            'success': result['success'],
            'output': result['stdout'] or result['stderr']
        })
    
    def handle_push(self, data):
        """推送代码"""
        commit_message = data.get('message', '更新应用代码')
        
        logs = []
        
        # 步骤1: 添加更改
        logs.append({'step': 1, 'message': '添加更改到暂存区...', 'type': 'info'})
        add_result = self.run_git_command('git add .')
        if not add_result['success']:
            logs.append({'step': 1, 'message': '添加失败: ' + add_result['stderr'], 'type': 'error'})
            self.send_json_response({'success': False, 'logs': logs})
            return
        logs.append({'step': 1, 'message': '添加完成', 'type': 'success'})
        
        # 步骤2: 提交代码
        logs.append({'step': 2, 'message': '提交代码...', 'type': 'info'})
        commit_result = self.run_git_command(f'git commit -m "{commit_message}"')
        # 如果没有更改，继续执行
        if 'nothing to commit' in commit_result['stdout']:
            logs.append({'step': 2, 'message': '没有需要提交的更改', 'type': 'warning'})
        elif not commit_result['success'] and 'nothing to commit' not in commit_result['stdout']:
            logs.append({'step': 2, 'message': '提交失败: ' + commit_result['stderr'], 'type': 'error'})
            self.send_json_response({'success': False, 'logs': logs})
            return
        else:
            logs.append({'step': 2, 'message': '提交完成', 'type': 'success'})
        
        # 步骤3: 获取当前分支
        branch_result = self.run_git_command('git branch --show-current')
        branch = branch_result['stdout'].strip()
        
        # 步骤4: 推送到 GitHub
        logs.append({'step': 3, 'message': f'推送到 GitHub ({branch})...', 'type': 'info'})
        push_result = self.run_git_command(f'git push origin {branch}')
        if not push_result['success']:
            logs.append({'step': 3, 'message': '推送失败: ' + push_result['stderr'], 'type': 'error'})
            self.send_json_response({'success': False, 'logs': logs})
            return
        logs.append({'step': 3, 'message': '推送完成', 'type': 'success'})
        
        # 步骤5: 触发构建
        logs.append({'step': 4, 'message': 'GitHub Actions 已自动触发构建', 'type': 'success'})
        
        # 获取仓库 URL
        remote_result = self.run_git_command('git remote get-url origin')
        repo_url = ''
        if remote_result['success']:
            repo_url = remote_result['stdout'].strip().replace('.git', '').replace('git@github.com:', 'https://github.com/')
        
        self.send_json_response({
            'success': True,
            'logs': logs,
            'repoUrl': repo_url
        })
    
    def handle_release(self, data):
        """发布版本"""
        version = data.get('version', '')
        commit_message = data.get('message', '')
        
        # 验证版本号
        if not re.match(r'^v?\d+\.\d+\.\d+$', version):
            self.send_json_response({
                'success': False,
                'message': '版本号格式不正确，请使用格式如: v1.0.0'
            })
            return
        
        # 确保版本号以 v 开头
        if not version.startswith('v'):
            version = 'v' + version
        
        if not commit_message:
            commit_message = f'发布版本 {version}'
        
        logs = []
        
        # 步骤1: 添加更改
        logs.append({'step': 1, 'message': '添加更改到暂存区...', 'type': 'info'})
        add_result = self.run_git_command('git add .')
        logs.append({'step': 1, 'message': '添加完成', 'type': 'success'})
        
        # 步骤2: 提交代码
        logs.append({'step': 2, 'message': '提交代码...', 'type': 'info'})
        commit_result = self.run_git_command(f'git commit -m "{commit_message}"')
        if 'nothing to commit' not in commit_result['stdout'] and not commit_result['success']:
            logs.append({'step': 2, 'message': '提交完成', 'type': 'success'})
        else:
            logs.append({'step': 2, 'message': '没有需要提交的更改', 'type': 'warning'})
        
        # 步骤3: 推送代码
        branch_result = self.run_git_command('git branch --show-current')
        branch = branch_result['stdout'].strip()
        
        logs.append({'step': 3, 'message': f'推送代码到 GitHub...', 'type': 'info'})
        push_result = self.run_git_command(f'git push origin {branch}')
        if not push_result['success']:
            logs.append({'step': 3, 'message': '推送失败: ' + push_result['stderr'], 'type': 'error'})
            self.send_json_response({'success': False, 'logs': logs})
            return
        logs.append({'step': 3, 'message': '推送完成', 'type': 'success'})
        
        # 步骤4: 创建标签
        logs.append({'step': 4, 'message': f'创建标签 {version}...', 'type': 'info'})
        tag_result = self.run_git_command(f'git tag {version}')
        if not tag_result['success']:
            logs.append({'step': 4, 'message': '标签可能已存在', 'type': 'warning'})
        else:
            logs.append({'step': 4, 'message': '标签创建完成', 'type': 'success'})
        
        # 步骤5: 推送标签
        logs.append({'step': 5, 'message': '推送标签到 GitHub...', 'type': 'info'})
        push_tag_result = self.run_git_command(f'git push origin {version}')
        if not push_tag_result['success']:
            logs.append({'step': 5, 'message': '推送标签失败: ' + push_tag_result['stderr'], 'type': 'error'})
            self.send_json_response({'success': False, 'logs': logs})
            return
        logs.append({'step': 5, 'message': '标签推送完成', 'type': 'success'})
        
        # 获取仓库 URL
        remote_result = self.run_git_command('git remote get-url origin')
        repo_url = ''
        if remote_result['success']:
            repo_url = remote_result['stdout'].strip().replace('.git', '').replace('git@github.com:', 'https://github.com/')
        
        self.send_json_response({
            'success': True,
            'logs': logs,
            'version': version,
            'repoUrl': repo_url
        })


def run_server(port=8765):
    """启动服务器"""
    server_address = ('', port)
    httpd = HTTPServer(server_address, GitAPIHandler)
    
    print(f"""
  ================================================================
       GitHub 自动推送工具 - 本地服务器
  ================================================================
  
  服务器已启动: http://localhost:{port}
  
  使用方法:
  1. 双击 "启动推送工具.bat" 启动工具
  2. 在浏览器中操作界面
  3. 按 Ctrl+C 停止服务器
  
  ================================================================
    """)
    
    # 自动打开浏览器
    def open_browser():
        webbrowser.open(f'http://localhost:{port}')
    
    threading.Thread(target=open_browser, daemon=True).start()
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n服务器已停止")
        httpd.shutdown()


if __name__ == '__main__':
    port = 8765
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            pass
    run_server(port)
