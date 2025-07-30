#!/usr/bin/env python
"""
ClaudeWarp 完整功能手动测试脚本
测试所有核心功能是否正常工作
"""

import subprocess
import sys
import os
import tempfile
from pathlib import Path


def run_command(cmd, input_text=None):
    """运行命令并返回结果"""
    print(f"\n🔧 执行命令: {cmd}")
    try:
        if input_text:
            print(f"📝 输入内容: {input_text}")
            result = subprocess.run(
                cmd, shell=True, capture_output=True, text=True, 
                input=input_text, timeout=30
            )
        else:
            result = subprocess.run(
                cmd, shell=True, capture_output=True, text=True, timeout=30
            )
        
        print(f"✅ 退出码: {result.returncode}")
        if result.stdout:
            print(f"📤 输出:\n{result.stdout}")
        if result.stderr:
            print(f"❌ 错误:\n{result.stderr}")
        return result
    except subprocess.TimeoutExpired:
        print("⏰ 命令超时")
        return None
    except Exception as e:
        print(f"💥 命令执行失败: {e}")
        return None


def test_basic_functionality():
    """测试基础功能"""
    print("=" * 60)
    print("🧪 开始基础功能测试")
    print("=" * 60)
    
    # 1. 测试帮助命令
    print("\n1️⃣ 测试帮助命令")
    run_command("cw --help")
    
    # 2. 测试列表命令（应该包含内置的no代理）
    print("\n2️⃣ 测试代理列表")
    result = run_command("cw list")
    if result and "no" in result.stdout:
        print("✅ 内置'no'代理存在于列表中")
    else:
        print("❌ 内置'no'代理未找到")
    
    # 3. 测试当前代理状态
    print("\n3️⃣ 测试当前代理状态")
    run_command("cw current")


def test_add_proxy_non_interactive():
    """测试非交互式添加代理"""
    print("\n4️⃣ 测试非交互式添加代理（API密钥）")
    run_command('cw add --name test-api --url https://api.example.com/ --key sk-test123456 --desc "测试API密钥代理" --interactive=False')
    
    print("\n5️⃣ 测试非交互式添加代理（Auth令牌）")
    run_command('cw add --name test-auth --url https://api2.example.com/ --auth-token sk-ant-api03-test123456 --desc "测试Auth令牌代理" --interactive=False')


def test_reserved_name():
    """测试保留名称验证"""
    print("\n6️⃣ 测试保留名称'no'验证")
    result = run_command('cw add --name no --url https://api.example.com/ --key sk-test123 --interactive=False')
    if result and result.returncode != 0:
        print("✅ 成功阻止了使用保留名称'no'")
    else:
        print("❌ 未能阻止使用保留名称'no'")


def test_no_proxy_functionality():
    """测试'no'代理功能"""
    print("\n7️⃣ 测试'no'代理功能")
    
    # 首先切换到一个普通代理
    print("先切换到test-api代理")
    run_command("cw use test-api")
    
    # 检查当前代理
    print("检查当前代理状态")
    run_command("cw current")
    
    # 使用'no'代理清空配置
    print("使用'no'代理清空配置")
    run_command("cw use no")
    
    # 再次检查当前代理状态
    print("检查清空后的代理状态")
    run_command("cw current")


def test_proxy_management():
    """测试代理管理功能"""
    print("\n8️⃣ 测试代理管理功能")
    
    # 查看所有代理
    run_command("cw list")
    
    # 查看代理详情
    run_command("cw info test-api")
    
    # 切换代理
    run_command("cw use test-auth")
    run_command("cw current")
    
    # 导出环境变量
    run_command("cw export --shell bash")


def test_cleanup():
    """清理测试数据"""
    print("\n9️⃣ 清理测试数据")
    run_command("cw remove test-api --force")
    run_command("cw remove test-auth --force")
    run_command("cw list")


def main():
    """主测试流程"""
    print("🚀 ClaudeWarp 完整功能测试")
    print("=" * 60)
    
    try:
        # 检查cw命令是否可用
        result = run_command("cw --version")
        if not result or result.returncode != 0:
            print("❌ cw命令不可用，请确保已安装项目")
            print("提示: 运行 'pip install -e .' 安装项目")
            return False
        
        # 依次执行测试
        test_basic_functionality()
        test_add_proxy_non_interactive()
        test_reserved_name()
        test_no_proxy_functionality()
        test_proxy_management()
        test_cleanup()
        
        print("\n" + "=" * 60)
        print("🎉 完整功能测试完成！")
        print("=" * 60)
        
        return True
        
    except KeyboardInterrupt:
        print("\n⚠️ 用户中断测试")
        return False
    except Exception as e:
        print(f"\n💥 测试过程中出现错误: {e}")
        return False


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)