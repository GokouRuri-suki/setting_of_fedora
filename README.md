# Fedora 配置备份（Dotfiles）

当前主机（Fedora，用户 `ruri`）的个性化配置，纳入 git 管理，便于迁移到新机器。

## 仓库结构

```
config/
├── nvim/                     # LazyVim：插件/主题/键位/汉化（lua/config + lua/plugins + lazy-lock.json）
├── zsh/                      # .zshrc（补全/高亮/历史/run_* 助手/icmake）+ .zprofile
├── cmake/                    # import-std.cmake + import-std-env.sh（C++23 import std 工具链）
└── starship/                 # starship.toml 提示符
assets/
└── ruri.png                  # fastfetch 头像
```

## 新机器安装步骤

### 1. 前置依赖（缺一不可，否则对应功能会崩）

| 工具 | 用途 | Fedora 安装 |
|------|------|-------------|
| `nvim` | 编辑器 | `sudo dnf install neovim` |
| `git`、`lazygit` | 版本控制 | `sudo dnf install git lazygit` |
| `starship` | 提示符 | `curl -sS https://starship.rs/install.sh \| sh` |
| `fastfetch` | 开机头像 | `sudo dnf install fastfetch` |
| `zsh-syntax-highlighting` | 语法高亮 | `sudo dnf install zsh-syntax-highlighting` |
| `zsh-autosuggestions` | 自动建议 | `sudo dnf install zsh-autosuggestions` |
| `nvm` | Node 版本管理 | 见 https://github.com/nvm-sh/nvm |
| `vcpkg` | C++ 包管理 | 克隆到 `~/vcpkg`（`.zshrc` 默认 `$HOME/vcpkg`） |
| `clangd` / `clang++` | C/C++ LSP / 编译器 | `sudo dnf install clang-tools-extra clang` |
| `libc++-devel` | C++ 标准库（含 `libc++.modules.json`） | `sudo dnf install libc++-devel` |
| `ninja-build` | import std 依赖的生成器 | `sudo dnf install ninja-build` |
| `gcc-c++` | `run_c/run_cpp` 助手需要（`-std=c++23` 需 GCC ≥ 13） | `sudo dnf install gcc-c++` |
| CMake ≥ 4.x | 构建 | `sudo dnf install cmake` |
| Mason → `neocmakelsp` | CMake LSP | 首次打开 nvim 自动装 |

> **软件包版本约束**：本仓库面向 **Fedora**（工具链/`lib64` 路径针对 Fedora 协商）。
> 字体需支持 **Nerd Font + CJK**，否则 starship 图标、nvim dashboard 与汉化显示异常。

### 工具链版本匹配（重要）

C++23 `import std` 工具链有一套**已知良好组合**（以你已跑通的 `study_for_cpp23` 项目、nvim 与 VS Code 配置为基准）：

| 组件 | 需要版本 | 说明 |
|------|----------|------|
| CMake | **4.3.x** | `import-std.cmake` 只对 4.3.x 设置实验 UUID |
| clang / clang++ | **22** | CMake 4.3 仅识别 Clang 22 的特性表 |
| libc++ | **22** | 提供 `/usr/lib64/libc++.modules.json` |
| 生成器 | **Ninja** | import std 只支持 Ninja |

对齐安装：`sudo dnf install cmake clang clang-tools-extra libc++-devel ninja-build`
- 若新机 CMake ≥ 4.4 / clang ≥ 23，以 `IMPORT_STD=1` 构建时会**打印 warning 明示版本不匹配**并跳过，而非静默失效。
- 本项目保留 clangd 的 `--experimental-modules-support --header-insertion=never`（与 VS Code `clangd.arguments` 一致，按 clangd 22 配置）；若新机 clangd 版本更高导致该 flag 失效，移除即可。

### 2. 克隆并链接

```bash
git clone <你的仓库地址> ~/code_file/setting_of_fedora
export DOTFILES="$HOME/code_file/setting_of_fedora"

ln -s "$DOTFILES/config/nvim"    ~/.config/nvim
ln -s "$DOTFILES/config/cmake"   ~/.config/cmake
ln -s "$DOTFILES/config/starship/starship.toml" ~/.config/starship.toml
ln -s "$DOTFILES/config/zsh/.zshrc"    ~/.zshrc
ln -s "$DOTFILES/config/zsh/.zprofile" ~/.zprofile
```

> 若仓库位置不同，请设置 `DOTFILES` 指向实际克隆位置（`.zshrc` 中的 fastfetch 头像用它定位）。

### 3. 启动

```bash
nvim   # 首次启动自动拉取 lazy.nvim，并按 lazy-lock.json 安装插件
```

## 可移植性说明

- 仓库内 `.zshrc` 已用 `$DOTFILES` / `$HOME` 替换硬编码路径（fastfetch 头像、vcpkg），跨机无需改。
- `clangd.lua` 走 `PATH` 发现 clangd 二进制；`--query-driver` 运行时用 `vim.fn.exepath("clang++")` 解析，找不到则不注入（不再写死 `/usr/bin`）。
- `import-std.cmake` 的 `libc++.modules.json` 会探测多个常见路径（`/usr/lib64`、`/usr/lib/x86_64-linux-gnu`、`/usr/lib`）。
- `lazyvim.json` 的 `extras` 声明了 `lazyvim.plugins.extras.editor.mini-files`（cf. mini-files 自定义在 `lua/plugins/mini-files.lua`）。
- `~/.local/share/nvim`（插件/Mason/数据）、`~/.zsh_history`、`~/.nvm`、`~/vcpkg` 不纳入仓库，新机重建。

## 备注

- 本次迁移为「只复制」：仓库内的配置是源，原 `~/.config/*` 与 `~/.zshrc` 未删除，由你自行决定是否改用软链。
- LazyVim 自带的 LICENSE / README 模板已移除。