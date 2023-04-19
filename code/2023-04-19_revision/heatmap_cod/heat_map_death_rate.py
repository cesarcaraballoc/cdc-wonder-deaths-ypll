import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sb
import numpy as np

df = pd.read_csv("/Users/shayaan/Downloads/Underlying Cause of Death, 1999-2020 (15).txt",
                 skipfooter=75,sep='\t',engine="python",usecols= [1,3,5,7,9,10,11,12,13])

df.columns = [c.replace(' ', '_') for c in df.columns]
df.columns = [c.replace('-', '_') for c in df.columns]
df.drop(df.index[df['ICD_10_113_Cause_List'] == "#COVID-19 (U07.1)"], inplace=True)
df.drop(df.index[df['ICD_10_113_Cause_List'] == "#Certain conditions originating in the perinatal period (P00-P96)"], inplace=True)
df.drop(df.index[df['Gender'] == "Male"], inplace=True)

df.drop(df.index[df['Crude_Rate'] == 'Unreliable'], inplace=True)
df.drop(df.index[df['Crude_Rate'] == 'Not Applicable'], inplace=True)
df['Crude_Rate'] = pd.to_numeric(df['Crude_Rate'], errors='coerce')
df['Crude_Rate'] = pd.to_numeric(df['Age_Adjusted_Rate'], errors='coerce')
df = df.dropna(how="any")

df2 = df[df.Race == "White"]
df3 = df[df.Race == "Black or African American"]
df2 = pd.merge(df2, df3, on = ["Year","Gender","ICD_10_113_Cause_List"])
df2["unadj_excess_num"] = df2["Deaths_y"] - (df2["Population_y"]*(df2["Deaths_x"]/df2["Population_x"]))
df2["unadj_excess_rate"] = df2["Crude_Rate_y"] - df2["Crude_Rate_x"]
df2["adj_excess_rate"] = df2["Age_Adjusted_Rate_y"] - df2["Age_Adjusted_Rate_x"]

df2 = df2.groupby(["Year","ICD_10_113_Cause_List"]).mean().reset_index()
df2 = df2[["Year","ICD_10_113_Cause_List","adj_excess_rate"]]
df2["Year"] = df2["Year"].astype(int)
df2 = df2.pivot("Year","ICD_10_113_Cause_List","adj_excess_rate")
pd.set_option("display.max_rows", None, "display.max_columns", None)

print(df2.min())
ax = plt.axes()
fig, ax = plt.subplots(figsize=(70,70))
g = sb.heatmap(df2, cmap = "Blues",xticklabels=1, yticklabels=1,ax = ax, vmin=-20,vmax=80)
g.set_xticklabels([""])   
g.set_xlabel("", fontsize = 10)
g.set_ylabel("Year", fontsize = 10)
ax.set_title("Age-Adjusted Excess Death Rate of Black Females Compared to White Females Per 100 000 People (1999-2020)")

fig.tight_layout()
plt.show()
