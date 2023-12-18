# %%

from datetime import datetime
import time

# version = datetime.today().strftime('%Y%m%d')
from shutil import copyfile, make_archive
import os
from distutils.dir_util import copy_tree
from distutils.dir_util import remove_tree

version = "v3.3.0"

# %%
for _ in range(2):
    try:
        remove_tree("./dist/yuhao")
    except:
        pass

# %%
os.makedirs("./dist/yuhao")
os.makedirs("./dist/yuhao/schema/yuhao")
copyfile("./image/yulight.png", f"./dist/yuhao/yulight_{version}.png")
copyfile("./beta/readme.md", f"./dist/yuhao/readme.txt")
copyfile("./beta/schema/yuhao/yuhao.full.dict.yaml", f"./dist/yuhao.full.dict.yaml")

copy_tree("./beta/mabiao", "./dist/yuhao/mabiao")
copy_tree("./beta/schema", "./dist/yuhao/schema")
copy_tree("./beta/hotfix", "./dist/yuhao/hotfix")

# %%
# Hamster IME
make_archive(f"./dist/hamster/yuhao_light_{version}", "zip", "./dist/yuhao/schema")

# # %%
# # copy yustar
# for file_name in [
#     "yustar.schema.yaml",
#     "yustar.dict.yaml",
#     "yustar_chaifen.schema.yaml",
#     "yustar_chaifen.dict.yaml",
#     "yuhao/yustar.full.dict.yaml",
#     "yuhao/yustar.quick.dict.yaml",
# ]:
#     copyfile(f"../yustar/beta/schema/{file_name}", f"./dist/yuhao/schema/{file_name}")

# %%
# Make zip
make_archive(f"./dist/yuhao_light_{version}", "zip", "./dist/yuhao")
copyfile(f"./dist/yuhao_light_{version}.zip", f"./dist/宇浩光華_{version}.zip")

# %%
try:
    remove_tree("./dist/yuhao")
except:
    print("Delete incomplete")
time.sleep(5)
try:
    remove_tree("./dist/yuhao")
except:
    print("Delete incomplete")
# %%
