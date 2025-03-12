# %%

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
    remove_tree("./dist/yujoy")
except Exception as e:
    print("Cannot remove dist/yujoy folder!")
    print(e)

try:
    os.makedirs("./dist/yujoy")
except Exception as e:
    print("Cannot create dist/yujoy folder!")
    print(e)

if re.match(r"^v\d+.\d+.\d+$", VERSION):
    shutil.copyfile(
        "./beta/schema/yuhao/yujoy.full.dict.yaml", "./dist/yujoy.full.dict.yaml"
    )

# %%
shutil.copyfile("./yujoy.pdf", f"./dist/yujoy/yujoy_{VERSION}.pdf")
shutil.copyfile("./beta/readme.md", "./dist/yujoy/readme.txt")
shutil.copyfile(
    f"{PROJECT_ROOT_PATH}/assets/fonts/Yuniversus.ttf",
    "./beta/font/Yuniversus.ttf",
)

copy_tree("./beta/mabiao/", "./dist/yujoy/mabiao/")
copy_tree("./beta/schema/", "./dist/yujoy/schema/")
copy_tree("./beta/custom/", "./dist/yujoy/custom/")
copy_tree("./beta/trime/", "./dist/yujoy/trime/")
copy_tree("./beta/font/", "./dist/yujoy/font/")

# %%
# copy yuhao
copy_tree("../lua/", "./dist/yujoy/schema/lua/")
for file_name in [
    # "yuhao.symbols.yaml",
    "yuhao_pinyin.dict.yaml",
    "yuhao_pinyin.schema.yaml",
    "yuhao/yuhao.symbols.dict.yaml",
    "yuhao/yuhao.extended.dict.yaml",
    "yuhao/yuhao.private.dict.yaml",
]:
    copyfile(f"../yulight/beta/schema/{file_name}", f"./dist/yujoy/schema/{file_name}")

copyfile(
    "../yulight/beta/schema/yuhao/yulight.roots.dict.yaml",
    "./dist/yujoy/schema/yuhao/yulight.roots.dict.yaml",
)
copyfile(
    "../yustar/beta/schema/yuhao/yustar.roots.dict.yaml",
    "./dist/yujoy/schema/yuhao/yustar.roots.dict.yaml",
)

for file_name in [
    # "yujoy_tc.schema.yaml",
    # "yujoy_tc.dict.yaml",
    # "yuhao/yujoy_tc.quick.dict.yaml",
    # "yuhao/yujoy_tc.words_literature.dict.yaml",
    # "yuhao/yujoy_tc.words.dict.yaml",
]:
    try:
        os.remove(f"./dist/yujoy/schema/{file_name}")
    except Exception as e:
        print(f"{file_name} does not exist. It is not deleted.")
        print(e)

for path, subdirs, files in os.walk("./"):
    for name in files:
        # get file path
        file_path = os.path.join(path, name)
        if ".DS_Store" in name:
            os.remove(file_path)
            print(f"Removed file {file_path}")
            break

# for file_name in [
#     "yujoy_tc.schema.yaml",
# ]:
#     os.remove(f"./dist/yujoy/hotfix/{file_name}")

# %%
shutil.make_archive(f"../dist/卿雲爛兮_{VERSION}", "zip", "./dist/yujoy")
shutil.make_archive(f"../dist/hamster/卿雲爛兮_{VERSION}", "zip", "./dist/yujoy/schema")

# %%
print(f"成功發佈卿雲 {VERSION}！")
