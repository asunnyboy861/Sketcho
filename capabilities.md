# Sketcho — 配置文档

生成时间：2026-09-16

---

## 一、⚠️ 手动配置（增强功能 — 不配置不影响基本使用）

> **重要说明**：App 已可下载即用——端侧渲染、风格切换、锁定模式、Before/After 对比、项目时间轴、导出、订阅付费墙全部内置且离线可用。以下配置项用于解锁完整云端能力与上架流程。

### 🔵 IAP StoreKit 配置（必须 — 否则用户无法完成内购）

**影响功能**：不创建 IAP 产品则付费墙无产品可买（免费层功能不受影响）

**已自动完成**：
- ✅ `Pay/StoreService.swift` StoreKit 2 代码已实现（5 个产品 ID 与 price.md 完全一致）
- ✅ Restore Purchases 按钮已在 Paywall 和 Settings 中实现

**手动配置步骤**：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com) → 我的 App → **Sketcho**（首次需先创建 App，Bundle ID 选择 `com.zzoutuo.Sketcho`）
2. 左侧菜单 → **功能 (Features)** → **App 内购买项目 (In-App Purchases)** → 点击 **"+"**
3. 先创建**订阅组**，组名：`Sketcho Pro`
4. 在组内创建以下订阅产品（等级越高排越前：Studio > Pro）：

| 产品 | Reference Name | Product ID | 价格 | Display Name | Description |
|------|---------------|-----------|------|--------------|-------------|
| Studio 年付 | Sketcho Studio Annual | `com.zzoutuo.Sketcho.studio.yearly` | $199.00/年 | Sketcho Studio Annual | All Studio features, billed yearly. Save 45%. |
| Studio 月付 | Sketcho Studio Monthly | `com.zzoutuo.Sketcho.studio.monthly` | $29.99/月 | Sketcho Studio Monthly | Pro features plus batch 16 and client demo mode |
| Pro 终身 | Sketcho Pro Lifetime | `com.zzoutuo.Sketcho.pro.lifetime` | $149.00 买断（非消耗型） | Sketcho Pro Lifetime | All Pro features forever. BYO key unlimited renders. |
| Pro 年付 | Sketcho Pro Annual | `com.zzoutuo.Sketcho.pro.yearly` | $79.99/年 | Sketcho Pro Annual | All Pro features, billed yearly. Save 49%. |
| Pro 月付 | Sketcho Pro Monthly | `com.zzoutuo.Sketcho.pro.monthly` | $12.99/月 | Sketcho Pro Monthly | 4K export, Tap-to-Edit, Style Quad, full Lock Mode |

> ⚠️ 注意：`Pro Lifetime` 是 **非消耗型 (Non-Consumable)** 内购，不是订阅；其余 4 个是**自动续订订阅**。Display Name ≤35 字符、Description ≤55 字符，可直接从上表复制。

5. 创建后等待 Apple 处理（通常 1-2 小时）
6. 在 Xcode 中创建 **StoreKit Configuration File**（File → New → File → StoreKit Configuration File）用于本地沙盒测试，产品 ID 与上表一致
7. 在 App 的 Paywall / Settings 中点 **"Restore Purchases"** 验证流程

---

### 🟢 App Store Connect 审核信息配置（必须 — 防止 Guideline 2.1(a) 拒审）

**影响功能**：审核员需要知道如何测试 AI/订阅功能

**配置步骤**：
1. App Store Connect → 你的 App → **App Review Information**
2. 在 **Notes** 字段粘贴项目根目录 `app_review_info.md` 的 "Review Notes" 全部内容（含 BYO Key 说明、订阅测试信息、合规声明）
3. **Privacy Policy URL** 填：`https://asunnyboy861.github.io/Sketcho/privacy.html`
4. **Terms of Use (EULA)** 链接填：`https://asunnyboy861.github.io/Sketcho/terms.html`
5. **Support URL** 填：`https://asunnyboy861.github.io/Sketcho/support.html`

---

### 🟠 App Store ID 占位符替换（上架后一次性操作）

**影响功能**：Landing Page 的 "Download on the App Store" 按钮

**配置步骤**：
1. App 创建后，在 App Store Connect → App 信息 → 复制 **Apple ID**（数字）
2. 编辑仓库中 `docs/index.html`，把 `id[APP_STORE_ID]` 替换为 `id<实际数字>`
3. 提交推送后 GitHub Pages 自动更新

---

### ⚪ 可选增强：锁屏 Widget 扩展（不配置不影响任何功能）

**增强功能**：锁屏一键"渲染上次房间"（Siri 快捷指令已内置，无需此步骤即可用 "Hey Siri, Sketcho my sketch"）
**不配置的影响**：仅无锁屏 Widget，App 其他功能完全正常

**如需启用**：
1. Xcode → File → New → Target → **Widget Extension**，名称 `SketchoWidget`，勾选 Embed in App
2. Widget 中调用已有的 `RenderLastProjectIntent`（位于 `Intents/RenderIntent.swift`）即可复用全部逻辑

---

### 💡 用户侧说明（非开发者配置，App 内操作即可）

**云端 HD 渲染 / Shop the Look**：BYO Key 模式——用户在 App 内 **Settings → Advanced: Configure Custom API** 输入自己的 fal.ai key（云端 Flux 渲染）和/或 DeepSeek key（家具识别）即可无限使用。Key 只存设备 Keychain。不配置时 App 自动降级为增强端侧渲染（明确标注 "Preview quality"），所有核心功能照常可用。

---

## 二、✅ 自动配置记录（已由系统完成，无需操作）

### Capabilities 自动配置

| Capability | 说明 | 状态 |
|------------|------|------|
| 相机权限 | INFOPLIST_KEY_NSCameraUsageDescription 已注入 | ✅ 已配置 |
| 相册权限 | INFOPLIST_KEY_NSPhotoLibraryUsageDescription 已注入 | ✅ 已配置 |
| Siri 用途描述 | INFOPLIST_KEY_NSSiriUsageDescription 已注入（App Intents 无需 entitlement） | ✅ 已配置 |
| In-App Purchase | StoreKit 2 无需显式 entitlement，产品动态读取 | ✅ 已配置 |
| 出站网络 | 默认允许（HTTPS 反馈后端/云渲染/BYO API） | ✅ 已配置 |
| App Icon | Agnes Image 生成（暗色+琥珀暖光），universal/dark/tinted 三态配置 | ✅ 已配置 |
| Bundle ID | 已修正为 com.zzoutuo.Sketcho，自动签名（Team JP4TN5PTS3） | ✅ 已配置 |

### 后端服务

| 服务 | 说明 | 状态 |
|------|------|------|
| 联系客服后端 | Cloudflare Workers（feedback-board），URL 已硬编码进 ContactSupportView | ✅ 已部署 |
| GitHub Pages | 隐私/条款/支持/Landing 四页已部署，Actions 工作流已配置 | ✅ 已部署 |

### 代码生成

| 模块 | 说明 | 状态 |
|------|------|------|
| 核心功能 | 22 个 Swift 文件 / 18 个主功能，MVVM 架构 | ✅ 已完成 |
| AIRouter | 三层路由（BYO > 云端配额 > 端侧），30 秒超时降级，成本前置展示 | ✅ 已完成 |
| ContactSupportView | 7 主题磁贴、5 必填字段、后端对接、隐私文案 | ✅ 已完成 |
| StoreService | StoreKit 2，Transaction.currentEntitlement 响应式订阅状态 | ✅ 已完成 |
| PaywallView | 四档价格一屏展示 + 法律链接 + 自动续订披露 | ✅ 已完成 |
| QA 迭代 | 1 轮迭代修复 3 个问题，7 维度评分 4-5 分 | ✅ 已完成 |
| 合规验证 | BYO Key 13 项检查全部通过 | ✅ 已完成 |

### 部署

| 项目 | 说明 | 状态 |
|------|------|------|
| GitHub 仓库 | https://github.com/asunnyboy861/Sketcho（公开） | ✅ 已推送 |
| GitHub Pages | https://asunnyboy861.github.io/Sketcho/ | ✅ 已启用 |
| App Store 元数据 | keytext.md 已生成，15 项验证全部通过 | ✅ 已完成 |
| 定价配置 | price.md 已生成（订阅 + 买断混合模型） | ✅ 已完成 |

---

## 三、能力检测详情

> 以下为 PHASE 2 原始检测数据。

### Analysis

基于指南关键词检测（拍摄/拍照/相机 → 相机+相册；订阅/购买/会员 → IAP；Siri/快捷指令 → App Intents；锁屏 Widget → WidgetKit；云端渲染/BYO API → 出站网络；SwiftData 本地存储 → 无需能力）。

### No Configuration Needed

- 出站网络（云渲染/BYO API）— 默认允许
- Push Notifications — 指南未要求
- iCloud — 指南未要求（SwiftData 仅本地）
- 定位、HealthKit、Apple Watch — 指南未要求

### Verification

- iPhone 16 (iOS 26.4) 构建运行测试：✅ 通过
- iPad Pro 13-inch (M5) (iOS 26.4) 构建运行测试：✅ 通过
- xcodebuild 构建：BUILD SUCCEEDED
- 所有 entitlements 正确：✅（无需任何 entitlement，全部优雅降级）
