# %%

from datetime import datetime
import time

# VERSION = datetime.today().strftime('%Y%m%d')
import shutil
from shutil import copyfile, make_archive
import os
from distutils.dir_util import copy_tree
from distutils.dir_util import remove_tree
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
    remove_tree("./dist/yulight")
except Exception as e:
    print("Cannot remove dist/yulight folder!")
    print(e)

try:
    os.makedirs("./dist/yulight")
except Exception as e:
    print("Cannot create dist/yulight folder!")
    print(e)

if re.match(r"^v\d+.\d+.\d+$", VERSION):
    shutil.copyfile(
        "./beta/schema/yuhao/yulight.full.dict.yaml", "./dist/yulight.full.dict.yaml"
    )

# %%
os.makedirs("./dist/yulight/schema/yuhao")
copyfile("./yulight.png", f"./dist/yulight/yulight_{VERSION}.png")
copyfile("./beta/readme.md", f"./dist/yulight/readme.txt")
copyfile("../yujoy/beta/schema/yuhao.essay.txt", f"./beta/schema/yuhao.essay.txt")

copy_tree("./beta/mabiao", "./dist/yulight/mabiao")
copy_tree("./beta/schema", "./dist/yulight/schema")
copy_tree("./beta/trime", "./dist/yulight/trime")
copy_tree("./beta/custom", "./dist/yulight/custom")

copy_tree("../lua/", "./dist/yulight/schema/lua/")

# %%
# Hamster IME
make_archive(f"../dist/hamster/yuhao_light_{VERSION}", "zip", "./dist/yulight/schema")

# %%
# Make zip
make_archive(f"../dist/宇浩光華_{VERSION}", "zip", "./dist/yulight")
# copyfile(f"../dist/宇浩光華_{VERSION}.zip", f"../dist/yuhao_light_{VERSION}.zip")

# %%
print(f"成功發佈光華 {VERSION}！")
