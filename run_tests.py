#!/usr/bin/env python
"""
测试运行脚本
提供更友好的测试输出格式
"""

import subprocess
import sys
from pathlib import Path


def run_tests():
    """运行测试并格式化输出"""
    
    print("🧪 运行 ClaudeWarp 测试套件")
    print("=" * 50)
    
    # 基本的pytest命令，使用简洁输出
    cmd = [
        sys.executable, "-m", "pytest", 
        "tests/",
        "--tb=short",          # 简短的错误输出
        "--quiet",             # 安静模式，减少冗余输出
        "-v",                  # 详细模式显示测试名称
        "--disable-warnings",  # 禁用警告
        "--color=yes"          # 彩色输出
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        # 解析输出
        stdout = result.stdout
        stderr = result.stderr
        
        # 显示测试结果摘要
        if "FAILED" in stdout or "ERROR" in stdout:
            print("❌ 测试失败")
            print("\n" + "="*30 + " 失败详情 " + "="*30)
            print(stdout)
            if stderr:
                print("\n" + "="*30 + " 错误信息 " + "="*30)
                print(stderr)
        elif "passed" in stdout:
            print("✅ 所有测试通过!")
            
            # 提取测试统计信息
            lines = stdout.split('\n')
            for line in lines:
                if "passed" in line and ("failed" in line or "error" in line or "warning" in line):
                    print(f"📊 {line}")
                    break
            else:
                # 如果没有找到统计行，显示最后几行
                summary_lines = [line for line in lines[-10:] if line.strip()]
                if summary_lines:
                    print(f"📊 {summary_lines[-1]}")
        else:
            print("⚠️ 测试完成，但状态不明确")
            print(stdout)
            
        return result.returncode
        
    except Exception as e:
        print(f"❌ 运行测试时出错: {e}")
        return 1


def run_specific_tests():
    """运行特定的测试组"""
    
    print("🎯 运行内置代理测试")
    print("=" * 30)
    
    cmd = [
        sys.executable, "-m", "pytest", 
        "tests/test_manager.py::TestBuiltinProxies",
        "-v",
        "--tb=short",
        "--color=yes"
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        stdout = result.stdout
        
        if "FAILED" in stdout or "ERROR" in stdout:
            print("❌ 内置代理测试失败")
            print(stdout)
        else:
            print("✅ 内置代理测试通过!")
            
            # 显示通过的测试
            lines = stdout.split('\n')
            for line in lines:
                if "test_" in line and ("PASSED" in line or "✓" in line):
                    test_name = line.split("::")[-1].split()[0]
                    print(f"  ✓ {test_name}")
                    
        return result.returncode
        
    except Exception as e:
        print(f"❌ 运行特定测试时出错: {e}")
        return 1


def main():
    """主函数"""
    if len(sys.argv) > 1 and sys.argv[1] == "--builtin":
        return run_specific_tests()
    else:
        return run_tests()


if __name__ == "__main__":
    sys.exit(main())