# EasyLaunchPad 已有资产清单（ASSETS）

> **用途**：防止重复造轮子。任何新功能/新组件开工前必须先查本清单。
> **维护**：Full 模式第 1 步扫描填写；实现中发现新资产及时补充。
> **约束**：写新代码前未查清单 → 审查打回（见 GLOBAL-CONSTRAINTS C6）。
> 本文件为项目内容，update 永不覆盖。

## 工具函数

| 名称 | 路径 | 用途 | 备注 |
|---|---|---|---|
| （示例）formatDate | src/utils/formatDate.ts | 日期格式化 | 支持 i18n |

## UI 组件

| 名称 | 路径 | 用途 | 变体/状态 | 备注 |
|---|---|---|---|---|
| （示例）AppButton | src/components/AppButton.tsx | 按钮 | 3 种变体 | 项目封装 |

## API / 数据层

| 名称 | 路径 | 用途 | 备注 |
|---|---|---|---|
| （示例）usersApi | src/api/users.ts | 用户 CRUD | 需 token |

## 服务 / 基础设施

| 名称 | 路径 | 用途 | 备注 |
|---|---|---|---|
| StatusBarPanelController | Sources/Services/StatusBarPanelController.swift | 菜单栏状态项 + 非激活下拉面板（点击外部自动收起） | 替代 MenuBarExtra(.window)，修复偏好设置无响应 |

---

## 新写记录（找不到现成时的搜索路径与新写理由）

| 日期 | 新写内容 | 搜索路径（grep/codegraph 关键词） | 未命中理由 |
|---|---|---|---|
| | | | |
