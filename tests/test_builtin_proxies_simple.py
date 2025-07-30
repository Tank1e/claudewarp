#!/usr/bin/env python
"""
内置代理功能的简单测试
专门测试我们新增的"no"代理功能
"""

import tempfile
from pathlib import Path
from unittest.mock import patch
import pytest

from claudewarp.core.manager import ProxyManager, BUILTIN_PROXIES
from claudewarp.core.models import ProxyServer
from claudewarp.core.exceptions import ValidationError


class TestBuiltinProxiesSimple:
    """内置代理功能的简单测试"""

    @pytest.fixture
    def temp_manager(self):
        """创建临时的代理管理器"""
        with tempfile.TemporaryDirectory() as temp_dir:
            config_path = Path(temp_dir) / "config.toml"
            manager = ProxyManager(config_path=config_path)
            yield manager

    def test_builtin_no_proxy_exists(self):
        """测试内置'no'代理是否存在"""
        assert "no" in BUILTIN_PROXIES
        no_proxy = BUILTIN_PROXIES["no"]
        assert no_proxy.name == "no"
        assert no_proxy.base_url == "http://localhost/"
        assert no_proxy.api_key == "builtin-no-proxy"
        assert no_proxy.is_active == True
        assert "内置代理" in no_proxy.description
        assert "builtin" in no_proxy.tags
        assert "reset" in no_proxy.tags

    def test_cannot_add_proxy_named_no(self, temp_manager):
        """测试不能添加名为'no'的代理"""
        with pytest.raises(ValidationError) as exc_info:
            temp_manager.add_proxy(
                name="no",
                base_url="https://api.example.com/",
                api_key="sk-test123",
                description="尝试添加保留名称"
            )
        assert "'no' 是保留名称" in str(exc_info.value)

    def test_can_get_builtin_no_proxy(self, temp_manager):
        """测试可以获取内置'no'代理"""
        no_proxy = temp_manager.get_proxy("no")
        assert no_proxy.name == "no"
        assert no_proxy.base_url == "http://localhost/"
        assert "内置代理" in no_proxy.description

    def test_list_proxies_includes_builtin(self, temp_manager):
        """测试代理列表包含内置代理"""
        # 添加一个用户代理
        temp_manager.add_proxy(
            name="user-proxy",
            base_url="https://api.example.com/",
            api_key="sk-test123",
            description="用户代理"
        )

        # 获取所有代理列表
        all_proxies = temp_manager.list_proxies()
        assert "no" in all_proxies
        assert "user-proxy" in all_proxies
        assert len(all_proxies) == 2

    @patch('claudewarp.core.manager.ProxyManager._clear_claude_code_config')
    def test_switch_to_no_proxy_clears_config(self, mock_clear_config, temp_manager):
        """测试切换到'no'代理会清空配置"""
        # 模拟清空配置成功
        mock_clear_config.return_value = True

        # 首先添加一个用户代理并切换到它
        temp_manager.add_proxy(
            name="user-proxy",
            base_url="https://api.example.com/",
            api_key="sk-test123"
        )
        
        # 确认当前代理已设置
        assert temp_manager.config.current_proxy == "user-proxy"

        # 切换到'no'代理
        result_proxy = temp_manager.switch_proxy("no")

        # 验证结果
        assert result_proxy.name == "no"
        assert temp_manager.config.current_proxy is None  # 当前代理应该被清空
        mock_clear_config.assert_called_once()  # 确认调用了清空配置方法

    def test_builtin_proxy_is_active(self, temp_manager):
        """测试内置代理默认是启用的"""
        no_proxy = temp_manager.get_proxy("no")
        assert no_proxy.is_active == True

    def test_can_add_normal_proxies(self, temp_manager):
        """测试可以正常添加其他名称的代理"""
        # 这个应该成功
        proxy = temp_manager.add_proxy(
            name="normal-proxy",
            base_url="https://api.example.com/",
            api_key="sk-test123",
            description="正常代理"
        )
        
        assert proxy.name == "normal-proxy"
        assert temp_manager.config.current_proxy == "normal-proxy"

    def test_builtin_proxy_not_in_user_config(self, temp_manager):
        """测试内置代理不会保存到用户配置中"""
        # 内置代理应该存在于列表中
        all_proxies = temp_manager.list_proxies()
        assert "no" in all_proxies
        
        # 但不应该存在于用户配置的proxies字典中
        assert "no" not in temp_manager.config.proxies


if __name__ == "__main__":
    pytest.main([__file__, "-v"])