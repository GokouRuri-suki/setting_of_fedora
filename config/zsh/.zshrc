# Dotfiles 仓库位置（跨机可改，勿写死用户名）
export DOTFILES="${DOTFILES:-$HOME/code_file/setting_of_fedora}"

# 加载 Starship 提示符
eval "$(starship init zsh)"

# 启用 Zsh 补全系统（必须先于 autosuggestion）
autoload -Uz compinit && compinit

# 复用 bash 补全（如 cmake 自带的 /usr/share/bash-completion/completions/cmake）
autoload -Uz bashcompinit && bashcompinit

# 菜单式补全（Tab 后方向键选择）
zstyle ':completion:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' list-prompt '%SAt %p: TAB 更多 | ↓ 选择%s'

# 大小写不敏感 + 前缀/子串智能匹配
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
       'r:|=*' 'l:|=* r:|=*'

# 补全后光标移动策略
setopt AUTO_LIST          # 首次 Tab 自动列出候选
setopt AUTO_MENU          # 再次 Tab 进入菜单选择
setopt COMPLETE_IN_WORD   # 允许词中补全
setopt ALWAYS_TO_END      # 补全后光标跳转到词尾

# 开机自启 Fastfetch 老婆
fastfetch --logo "$DOTFILES/assets/ruri.png" --logo-type chafa --logo-height 28

# 加载 Zsh 插件（必须放在颜色设置之前！）
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

# 代码高亮配置
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff5555,bold'          # 打错的命令
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#f1fa8c,bold'          # if/for/while 保留字
ZSH_HIGHLIGHT_STYLES[command]='fg=#bd93f9,bold'                # 正常命令（亮紫）
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#bd93f9,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#bd93f9,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#bd93f9,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#bd93f9,bold'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#bd93f9,bold'           # 后缀别名如 |x
ZSH_HIGHLIGHT_STYLES[precommand]='fg=yellow,bold'             # sudo 等（微微亮黄）
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ff5555'            # ; && ||
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#8be9fd'
ZSH_HIGHLIGHT_STYLES[path]='fg=#8be9fd'                        # 存在的路径（青色）
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#8be9fd'          # 路径分隔符 /
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#8be9fd'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#4aff7b'                    # *.txt 通配（绿）
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#ff79c6'           # !! !$
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#7aa2f7'        # -x（蓝）
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#7aa2f7'        # --flag（蓝）
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f1fa8c'      # 单引号字符串
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f1fa8c'      # 双引号字符串
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#ff79c6' # 引号内 $var
ZSH_HIGHLIGHT_STYLES[comment]='fg=244'                          # # 注释（低调灰）
ZSH_HIGHLIGHT_STYLES[assign]='fg=#ff79c6'                      # 变量赋值
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#ff5555'                 # > | 2>
ZSH_HIGHLIGHT_STYLES[numeric-literal]='fg=#ffb86c'             # 数字
ZSH_HIGHLIGHT_STYLES[cursor]='standout'
export PATH="$HOME/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
setopt PROMPT_SUBST

#vcpkg
export VCPKG_HOME="$HOME/vcpkg/"
export PATH=$VCPKG_HOME:$PATH

# CMake 全局启用 import std
[ -f "$HOME/.config/cmake/import-std-env.sh" ] && source "$HOME/.config/cmake/import-std-env.sh"

# 终端里构建 C++23 import std 项目（clang+libc++，与 VS Code 一致）
icmake() { IMPORT_STD=1 cmake "$@"; }

# zsh 命令历史记录
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# ===== run_* 运行助手(先构建后运行):c / cpp =====
run_c() {
  local o="${1%.c}"
  gcc -O0 -g "$1" -o "$o" && "./$o"
}

run_cpp() {
  if [[ -f CMakeLists.txt ]]; then
    local tgt
    tgt=$(sed -nE 's/^add_executable\(([A-Za-z_][A-Za-z0-9_-]*).*/\1/p' CMakeLists.txt | head -1)
    cmake --build build && ./build/"$tgt"
  else
    local o="${1%.cpp}"
    g++ -O0 -g -std=c++23 "$1" -o "$o" && "./$o"
  fi
}
