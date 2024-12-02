# %%

import shutil
import os
from distutils.dir_util import copy_tree
from distutils.dir_util import remove_tree
from shutil import copyfile
import re

version = "v3.6.1-beta.20241202"

# %%
try:
    remove_tree("./dist/yujoy")
except:
    print("Cannot remove dist/yujoy folder!")

try:
    os.makedirs("./dist/yujoy")
except:
    print("Cannot create dist/yujoy folder!")

if re.match(r"^v\d+.\d+.\d+$", version):
    shutil.copyfile(
        "./beta/schema/yuhao/yujoy.full.dict.yaml", f"./dist/yujoy.full.dict.yaml"
    )

# %%
shutil.copyfile("./yujoy.png", f"./dist/yujoy/yujoy_{version}.png")
shutil.copyfile("./beta/readme.md", f"./dist/yujoy/readme.txt")
shutil.copyfile(
    "../../../Programs/YuhaoInputMethod/YuhaoRoots/Yuniversus.ttf",
    "./beta/font/Yuniversus.ttf",
)

copy_tree("./beta/mabiao/", "./dist/yujoy/mabiao/")
copy_tree("./beta/schema/", "./dist/yujoy/schema/")
copy_tree("./beta/custom/", "./dist/yujoy/custom/")
# copy_tree("./beta/hotfix/", "./dist/yujoy/hotfix/")
copy_tree("./beta/trime/", "./dist/yujoy/trime/")
copy_tree("./beta/font/", "./dist/yujoy/font/")

# %%
# copy yuhao
copy_tree("../lua/", "./dist/yujoy/schema/lua/")
for file_name in [
    "yuhao.symbols.yaml",
    "yuhao_pinyin.dict.yaml",
    "yuhao_pinyin.schema.yaml",
    "yuhao/yuhao.symbols.dict.yaml",
    "yuhao/yuhao.extended.dict.yaml",
    "yuhao/yuhao.private.dict.yaml",
]:
    copyfile(f"../yulight/beta/schema/{file_name}", f"./dist/yujoy/schema/{file_name}")

for file_name in [
    "yujoy_tc.schema.yaml",
    "yujoy_tc.dict.yaml",
    "yuhao/yujoy_tc.quick.dict.yaml",
    # "yuhao/yujoy_tc.words_literature.dict.yaml",
    # "yuhao/yujoy_tc.words.dict.yaml",
]:
    try:
        os.remove(f"./dist/yujoy/schema/{file_name}")
    except:
        print(f"{file_name} does not exist. It is not deleted.")

# for file_name in [
#     "yujoy_tc.schema.yaml",
# ]:
#     os.remove(f"./dist/yujoy/hotfix/{file_name}")

# %%
shutil.make_archive(f"../dist/卿雲爛兮_{version}", "zip", "./dist/yujoy")
shutil.make_archive(f"../dist/hamster/卿雲爛兮_{version}", "zip", "./dist/yujoy/schema")
