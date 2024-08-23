# %%

from datetime import datetime
import time

# version = datetime.today().strftime('%Y%m%d')
import shutil
import os
from distutils.dir_util import copy_tree
from distutils.dir_util import remove_tree
from shutil import copyfile
import re

version = "v3.6.0-rc.4"

if re.match(r"^v\d+.\d+.\d+$", version):
    shutil.copyfile(
        "./beta/schema/yuhao/yustar.full.dict.yaml", f"./dist/yustar.full.dict.yaml"
    )

# %%
try:
    remove_tree("./dist/yustar")
except:
    os.makedirs("./dist/yustar")

# %%
# Copy yustar
# shutil.copyfile("./image/yustar.png", f"./dist/yustar/yustar_{version}.png")
shutil.copyfile("./beta/readme.md", f"./dist/yustar/readme.txt")
shutil.copyfile(
    "../../../Programs/YuhaoInputMethod/YuhaoRoots/Yuniversus.ttf",
    "./beta/font/Yuniversus.ttf",
)
shutil.copyfile(
    "../yujoy/beta/schema/yuhao.essay.txt", f"./beta/schema/yuhao.essay.txt"
)

copy_tree("./beta/mabiao/", "./dist/yustar/mabiao/")
copy_tree("./beta/schema/", "./dist/yustar/schema/")
copy_tree("../yulight/beta/schema/lua/", "./dist/yustar/hotfix/lua/")
copy_tree("./beta/hotfix/", "./dist/yustar/hotfix/")
copy_tree("./beta/custom/", "./dist/yustar/custom/")
copy_tree("./beta/trime/", "./dist/yustar/trime/")
copy_tree("./beta/font/", "./dist/yustar/font/")

# %%
# copy yuhao
copy_tree("../yulight/beta/schema/lua/", "./dist/yustar/schema/lua/")
for file_name in [
    "yuhao.symbols.yaml",
    "yuhao_pinyin.dict.yaml",
    "yuhao_pinyin.schema.yaml",
    "yuhao/yuhao.extended.dict.yaml",
    "yuhao/yuhao.private.dict.yaml",
    "yuhao/yuhao.symbols.dict.yaml",
]:
    copyfile(f"../yulight/beta/schema/{file_name}", f"./dist/yustar/schema/{file_name}")

# %%
shutil.make_archive(f"../dist/宇浩星陳_{version}", "zip", "./dist/yustar")
# copyfile(f"../dist/宇浩星陳_{version}.zip", f"../dist/yuhao_star_{version}.zip")

shutil.make_archive(
    f"../dist/hamster/yuhao_star_{version}", "zip", "./dist/yustar/schema"
)

# %%
