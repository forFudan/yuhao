# %%

from datetime import datetime
# version = datetime.today().strftime('%Y%m%d')
import shutil
import os
from distutils.dir_util import copy_tree
from distutils.dir_util import remove_tree

version = "v2.4.8"

#%%
try:
    remove_tree("./dist/yuhao")
except:
    pass

# remove_tree("./wafel")

#%%
os.makedirs("./dist/yuhao")
shutil.copyfile("./image/宇浩输入法宋体字根图v2olkb.png", f"./dist/yuhao/宇浩输入法宋体字根图{version}.png")
copy_tree("./beta/mabiao", "./dist/yuhao/mabiao")
copy_tree("./beta/schema", "./dist/yuhao/schema")

shutil.make_archive(f"./dist/yuhao_{version}", 'zip', "./dist/yuhao")
# %%
shutil.make_archive(f"./dist/yuhao_{version}_hotfix", 'zip', "./beta/hotfix")
# %%
