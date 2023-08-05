# %%
import pandas as pd

# %%
# smyh_simp.txt

orig = pd.read_csv(
    "wafel/generator/三碼宇浩一二簡設置簡體.csv"
)

# %%
simpa = orig[["一", "码位"]].copy()
simpa["码位"] += "1"
simpa.columns = ['char', "code"]

simpb = orig[["二", "码位"]].copy()
simpb["码位"] += "2"
simpb.columns = ['char', "code"]

simpc = orig[["三", "码位"]].copy()
simpc["码位"] += "3"
simpc.columns = ['char', "code"]

simp = pd.concat([simpa, simpb, simpc])
simp = simp[simp["char"].notna()]
# %%
simp
# %%
char = simp[simp["char"].map(len)==1]
word = simp[simp["char"].map(len)>1]
# %%
char.to_csv("wafel/smyh/smyh_simp.txt", sep="\t", index=False, header=False)
word.to_csv("wafel/smyh/smyh_quick.txt", sep="\t", index=False, header=False)
# %%
