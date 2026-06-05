import subprocess
import re
import requests
import webbrowser
import time
import os
import sys

# 配置变量
BASE_URI = "http://a1.easemob.com/easemob-demo/qianyitest"
AUTH_TOKEN = os.environ.get("IM_REST_AUTH_TOKEN", "Bearer <YOUR_TOKEN_HERE>")
def get_ngrok_url():
    # 先尝试终止可能存在的ngrok进程
    try:
        subprocess.run(["pkill", "ngrok"], capture_output=True)
        print("Terminated existing ngrok processes")
    except Exception as e:
        print(f"Error terminating ngrok processes: {e}")

    # 杀掉占用8089端口的进程
    try:
        # 使用lsof查找占用8089端口的进程
        result = subprocess.run(["lsof", "-t", "-i:8089"], capture_output=True, text=True)
        if result.stdout:
            pids = result.stdout.strip().split('\n')
            for pid in pids:
                if pid:
                    subprocess.run(["kill", pid], capture_output=True)
                    print(f"Terminated process {pid} using port 8089")
        else:
            print("No process using port 8089")
    except Exception as e:
        print(f"Error terminating processes on port 8089: {e}")

    # 启动ngrok进程
    process = subprocess.Popen(
        ["ngrok", "http", "8089"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,  # 合并stdout和stderr
        text=True
    )

    # 等待并读取输出，提取Forwarding URL
    forwarding_url = None
    start_time = time.time()
    timeout = 20  # 增加超时时间到20秒
    time.sleep(5)  # 等待ngrok启动

    # 尝试从ngrok API获取隧道信息
    try:
        response = requests.get("http://127.0.0.1:4040/api/tunnels", timeout=3)
        if response.status_code == 200:
            data = response.json()
            for tunnel in data.get("tunnels", []):
                if tunnel.get("proto") == "https":
                    forwarding_url = tunnel.get("public_url")
                    print(f"Got ngrok URL from API: {forwarding_url}")
                    return None, forwarding_url
    except Exception as e:
        print(f"Error checking ngrok API (attempt {i+1}/3): {e}")

    # 尝试使用ngrok命令行直接启动并获取URL
    print("Starting ngrok http 8089...")
    

    while time.time() - start_time < timeout:
        # 读取进程输出
        try:
            line = process.stdout.readline()
            if line:
                print(f"ngrok output: {line.strip()}")
                # 匹配Forwarding URL
                match = re.search(r"Forwarding\s+https://([a-zA-Z0-9-]+\.ngrok-free\.app)", line)
                if match:
                    forwarding_url = f"https://{match.group(1)}"
                    print(f"Got ngrok URL: {forwarding_url}")
                    # 等待几秒钟确保隧道完全建立
                    time.sleep(3)
                    return process, forwarding_url
                
                # 检查错误信息
                if "ERROR:" in line:
                    print(f"ngrok error: {line.strip()}")
                    # 尝试从API获取
                    try:
                        response = requests.get("http://127.0.0.1:4040/api/tunnels", timeout=2)
                        if response.status_code == 200:
                            data = response.json()
                            for tunnel in data.get("tunnels", []):
                                if tunnel.get("proto") == "https":
                                    forwarding_url = tunnel.get("public_url")
                                    print(f"Got ngrok URL from API: {forwarding_url}")
                                    return process, forwarding_url
                    except Exception as e:
                        print(f"Error checking ngrok API: {e}")
        except Exception as e:
            print(f"Error reading ngrok output: {e}")
        
        time.sleep(0.5)
    
    if not forwarding_url:
        print("Failed to get ngrok URL. Exiting.")
        process.terminate()
        exit(1)
    
    return process, forwarding_url

def send_webhook_request(ngrok_url):
    # 构造请求数据
    url = f"{BASE_URI}/msghooks"
    payload = {
        "name": "rated",
        "msgTypes": ["TEXT", "IMAGE", "VIDEO", "LOCATION", "VOICE", "FILE", "COMMAND"],
        "interested": ["groupchat", "chat", "chatroom"],
        "targetUrl": ngrok_url,
        "defaultAction": 1,
        "status": 1,
        "error_code": 1,
        "timeout": 2000,
        "label": 0
    }
    
    headers = {
        "Authorization": AUTH_TOKEN,
        "Content-Type": "application/json"
    }
    
    # 打印请求信息以便调试
    print(f"Request URL: {url}")
    print(f"Request headers: {headers}")
    print(f"Request payload: {payload}")
    
    print(f"Sending webhook request with targetUrl: {ngrok_url}")
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        print(f"Response status code: {response.status_code}")
        print(f"Response content: {response.text}")
    except Exception as e:
        print(f"Error sending request: {e}")

def start_callback_script():
    # 启动Callback.py脚本
    callback_path = "/Users/easemob/Data/tools/Callback.py"
    if os.path.exists(callback_path):
        print(f"Starting Callback.py at {callback_path}...")
        subprocess.Popen(["python3", callback_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    else:
        print(f"Callback.py not found at {callback_path}")

def open_browser():
    # 打开浏览器访问 http://127.0.0.1:4040
    print("Opening browser to http://127.0.0.1:4040...")
    webbrowser.open("http://127.0.0.1:4040")

def send_callback_request(ngrok_url):
    # 构造请求数据
    url = f"{BASE_URI}/callbacks"
    payload = {
        "name": "Callback1",
        "messageOriginTypes": ["SDK", "REST"],
        "interested": ["chat", "groupchat", "chatroom", "recall"],
        "msgTypes": ["chat", "chat_offline"],
        "targetUrl": ngrok_url,
        "status": 1
    }
    
    headers = {
        "Authorization": AUTH_TOKEN,
        "Content-Type": "application/json"
    }
    
    # 打印请求信息以便调试
    print(f"\nSending callback request...")
    print(f"Request URL: {url}")
    print(f"Request headers: {headers}")
    print(f"Request payload: {payload}")
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        print(f"Response status code: {response.status_code}")
        print(f"Response content: {response.text}")
    except Exception as e:
        print(f"Error sending callback request: {e}")

def main():
    # 检查命令行参数
    ngrok_url = None
    if len(sys.argv) > 1:
        ngrok_url = sys.argv[1]
        print(f"Using provided ngrok URL: {ngrok_url}")
    else:
        # 获取ngrok URL
        time.sleep(5)
        ngrok_process, ngrok_url = get_ngrok_url()
    
    # 发送webhook请求
    send_webhook_request(ngrok_url)
    
    # 发送callback请求
    send_callback_request(ngrok_url)
    
    # 启动Callback.py
    start_callback_script()
    
    # 打开浏览器
    open_browser()
    
    # 保持脚本运行，确保ngrok持续运行
    print("Setup completed. Press Ctrl+C to exit.")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Exiting...")
        if 'ngrok_process' in locals() and ngrok_process:
            ngrok_process.terminate()

if __name__ == "__main__":
    main()
