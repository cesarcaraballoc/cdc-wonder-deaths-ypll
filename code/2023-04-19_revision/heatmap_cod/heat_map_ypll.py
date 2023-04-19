import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sb
import numpy as np

df = pd.read_csv("/Users/shayaan/Downloads/Underlying Cause of Death, 1999-2020 (14).txt",
                 skipfooter=75,sep='\t',engine="python",usecols= [1,3,5,7,10,11,12,13])


df.columns = [c.replace(' ', '_') for c in df.columns]
df.columns = [c.replace('-', '_') for c in df.columns]

df.drop(df.index[df['Gender'] == "Male"], inplace=True)
df.drop(df.index[df['ICD_10_113_Cause_List'] == "#Certain conditions originating in the perinatal period (P00-P96)"], inplace=True)
df.drop(df.index[df['Race'] == "American Indian or Alaska Native"], inplace=True)
df.drop(df.index[df['Race'] == "Asian or Pacific Islander"], inplace=True)

df.drop(df.index[df['Five_Year_Age_Groups_Code'] == 'NS'], inplace=True)
df.drop(df.index[df['Crude_Rate'] == 'Unreliable'], inplace=True)
df.drop(df.index[df['Crude_Rate'] == 'Not Applicable'], inplace=True)
df['Crude_Rate'] = pd.to_numeric(df['Crude_Rate'], errors='coerce')

df = df.dropna(how="any")

df["Five_Year_Age_Groups_Code"] = df["Five_Year_Age_Groups_Code"].str[:2]
df["Five_Year_Age_Groups_Code"] = df["Five_Year_Age_Groups_Code"].replace("-","",regex=True)
df.Five_Year_Age_Groups_Code = pd.to_numeric(df['Five_Year_Age_Groups_Code'])

df["age_cat"] = pd.cut(df.Five_Year_Age_Groups_Code, bins=[0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100], labels = [0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95])
df.groupby(["Year","age_cat","Gender","Race",]).mean()


df1 = pd.read_csv("/Users/shayaan/Downloads/2022-05-12_code_export/text/file_life_expectancy_1999_to_2020.csv")
df1.rename(columns = {'year':'Year', 'gender':'Gender'}, inplace = True)
df = pd.merge(df, df1, on = ["Year", "age_cat","Gender"])
df["yrs_lost"] = df["life_expectancy"]*df["Crude_Rate"]

df2 = df[df.Race == "White"]
df3 = df[df.Race == "Black or African American"]
df2 = pd.merge(df2, df3, on = ["Year", "age_cat","Gender","ICD_10_113_Cause_List"])
df2["excess"] = df2["yrs_lost_y"] - df2["yrs_lost_x"]
df2 = df2.groupby(["Year","ICD_10_113_Cause_List"]).mean().reset_index()
df2 = df2[["Year","ICD_10_113_Cause_List","excess"]]
df2["Year"] = df2["Year"].astype(int)
df2 = df2.pivot("Year","ICD_10_113_Cause_List","excess")
pd.set_option("display.max_rows", None, "display.max_columns", None)


fig = plt.subplots(figsize=(70,70))
g = sb.heatmap(df2, cmap = "Blues",xticklabels=1, yticklabels=1,vmin = -900, vmax = 3200)
g.set_xticklabels(["Accidents","Alzheimer's","Assault", "Cerebrovascular Diseases","Chronic Liver Disease and Cirrhosis","Chronic Lower Respiratory Diseases","Diabetes","Heart Disease","Hypertension","HIV","Influenza and Pneumonia","Suicide","Cancer","Nephritis","Parkinson's","Pneumonitis due to solids and liquids","Septicemia"])   
g.set_xlabel("Cause of Death", fontsize = 10)
g.set_ylabel("Year", fontsize = 10)
g.set_title("Age-Adjusted Excess Years of Potential Life Lost By Black Females Compared to White Females Per 100 000 People (1999-2020)")
plt.show()
