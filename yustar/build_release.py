# %%

from datetime import datetime
import time

# VERSION = datetime.today().strftime('%Y%m%d')
import shutil
import os
from distutils.dir_util import copy_tree
from distutils.dir_util import remove_tree
from shutil import copyfile
import re
from sys import platform

VERSION = "v3.8.0"

if platform == "darwin":
    PROJECT_ROOT_PATH = "/Users/ZHU/Dropbox/Programs/YuhaoInputMethod"
elif platform == "win32":
    PROJECT_ROOT_PATH = "C:/Users/yuzhu/Dropbox/Programs/YuhaoInputMethod"
else:
    raise Exception("Unknown platform!")

# %%
try:
    remove_tree("./dist/yustar")
except Exception as e:
    print("Cannot remove dist/yustar folder!")
    print(e)

try:
    os.makedirs("./dist/yustar")
except Exception as e:
    print("Cannot create dist/yustar folder!")
    print(e)

if re.match(r"^v\d+.\d+.\d+$", VERSION):
    shutil.copyfile(
        "./beta/schema/yuhao/yustar.full.dict.yaml", "./dist/yustar.full.dict.yaml"
    )

# %%
# Copy yustar
shutil.copyfile("./yustar.pdf", f"./dist/yustar/yustar_{VERSION}.pdf")
shutil.copyfile("./beta/readme.md", "./dist/yustar/readme.txt")
shutil.copyfile(
    f"{PROJECT_ROOT_PATH}/assets/fonts/Yuniversus.ttf",
    "./beta/font/Yuniversus.ttf",
)
shutil.copyfile("../yujoy/beta/schema/yuhao.essay.txt", "./beta/schema/yuhao.essay.txt")

copy_tree("./beta/mabiao/", "./dist/yustar/mabiao/")
copy_tree("./beta/schema/", "./dist/yustar/schema/")
copy_tree("./beta/custom/", "./dist/yustar/custom/")
copy_tree("./beta/trime/", "./dist/yustar/trime/")
copy_tree("./beta/font/", "./dist/yustar/font/")

# %%
# copy yuhao
copy_tree("../lua/", "./dist/yustar/schema/lua/")
for file_name in [
    # "yuhao.symbols.yaml",
    "yuhao_pinyin.dict.yaml",
    "yuhao_pinyin.schema.yaml",
    "yuhao/yuhao.extended.dict.yaml",
    "yuhao/yuhao.private.dict.yaml",
    "yuhao/yuhao.symbols.dict.yaml",
]:
    copyfile(f"../yulight/beta/schema/{file_name}", f"./dist/yustar/schema/{file_name}")

# %%
shutil.make_archive(f"../dist/宇浩星陳_{VERSION}", "zip", "./dist/yustar")
# copyfile(f"../dist/宇浩星陳_{VERSION}.zip", f"../dist/yuhao_star_{VERSION}.zip")

shutil.make_archive(
    f"../dist/hamster/yuhao_star_{VERSION}", "zip", "./dist/yustar/schema"
)

# %%
print(f"成功發佈星陳 {VERSION}！")
