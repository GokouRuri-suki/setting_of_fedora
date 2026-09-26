# 由 CMAKE_TOOLCHAIN_FILE 环境变量自动加载，对所有项目生效
# 已知良好组合：CMake 4.3.x · Clang 22 · libc++ 22 · Ninja（参考 study_for_cpp23 项目与 nvim/VS Code 配置）
# 只在 CMake 4.3.x 上启用对应 UUID，其它版本不动，避免静默出错
if(CMAKE_VERSION VERSION_GREATER_EQUAL "4.3" AND CMAKE_VERSION VERSION_LESS "4.4")
  set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
      "451f2fe2-a8a2-47c3-bc32-94786d8fc91b"
      CACHE STRING "CMake 4.3.x import std gate")
elseif(DEFINED ENV{IMPORT_STD} AND "$ENV{IMPORT_STD}" STREQUAL "1")
  # 显式请求 import std，但工具链版本不匹配（多为 CMake ≥4.4 / Clang ≥23）
  message(WARNING
    "import std: 工具链版本不匹配，已跳过。需要 CMake 4.3.x + Clang 22 + libc++ 22 的组合，见仓库 README「版本匹配」。")
endif()

# import std 只被 Ninja 生成器支持；其它生成器不强行开启，避免报错
if(CMAKE_GENERATOR MATCHES "Ninja")
  set(CMAKE_CXX_MODULE_STD ON CACHE BOOL "enable C++ standard library module")
endif()

# 仅当带 IMPORT_STD=1 标记（VS Code CMake Tools / icmake）时才强制 clang+libc++，
# 其它项目（如 STM32/CLion 默认配置）完全不受影响
if(DEFINED ENV{IMPORT_STD} AND "$ENV{IMPORT_STD}" STREQUAL "1" AND CMAKE_GENERATOR MATCHES "Ninja")
  if(NOT DEFINED CMAKE_C_COMPILER)
    set(CMAKE_C_COMPILER clang)
  endif()
  if(NOT DEFINED CMAKE_CXX_COMPILER)
    set(CMAKE_CXX_COMPILER clang++)
  endif()
  set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -stdlib=libc++")
  set(CMAKE_EXE_LINKER_FLAGS_INIT "${CMAKE_EXE_LINKER_FLAGS_INIT} -stdlib=libc++")
  # project() 之前的 try_compile 也要知道 std 模块元数据（libc++）
  # 探测常见安装路径，避免写死 /usr/lib64（新机发行版可能不同）
  foreach(_cand
      "/usr/lib64/libc++.modules.json"
      "/usr/lib/x86_64-linux-gnu/libc++.modules.json"
      "/usr/lib/libc++.modules.json")
    if(EXISTS "${_cand}")
      set(CMAKE_CXX_STDLIB_MODULES_JSON "${_cand}" CACHE FILEPATH "libc++ std module metadata")
      break()
    endif()
  endforeach()
  # 注意：不要在这里设 CMAKE_CXX_STANDARD —— project() 前设置会让 try_compile
  # 因 CMake 4.3 不认识 Clang 22 的特性表而失败；应由项目 CMakeLists 设置
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "")
endif()
