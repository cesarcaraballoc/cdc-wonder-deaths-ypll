import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sb

"""
DR Male
"""

df = pd.read_csv("/Users/shayaan/Downloads/Underlying Cause of Death, 1999-2020 (15).txt",
                 skipfooter=75,sep='\t',engine="python",usecols= [1,3,5,7,9,10,11,12,13])

df.columns = [c.replace(' ', '_') for c in df.columns]
df.columns = [c.replace('-', '_') for c in df.columns]
df.drop(df.index[df['ICD_10_113_Cause_List'] == "#COVID-19 (U07.1)"], inplace=True)
df.drop(df.index[df['Gender'] == "Female"], inplace=True)

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
df2.columns = ["Accidents","Alzheimer's","Assault", "Cerebrovascular Diseases","Conditions From Perinatal Period", "Chronic Liver Disease and Cirrhosis","Chronic Lower Respiratory Diseases","Diabetes","Heart Disease","Hypertension","HIV","Influenza and Pneumonia","Suicide","Cancer","Nephritis","Parkinson's","Pneumonitis due to solids and liquids","Septicemia"]

df2 = df2.transpose()
df2["Most_deaths"] = df2.mean(axis=1)
df2 = df2.sort_values(by = "Most_deaths",ascending = False)
df2 = df2.reindex(["Heart Disease", "Cancer", "Assault", "Cerebrovascular Diseases", "Diabetes", "HIV", "Nephritis", "Septicemia", "Hypertension", "Conditions From Perinatal Period", "Influenza and Pneumonia", "Pneumonitis due to solids and liquids", "Accidents", "Alzheimer's", "Chronic Liver Disease and Cirrhosis", "Parkinson's", "Chronic Lower Respiratory Diseases", "Suicide"])

"""
DR female
"""

p4 = pd.read_csv("/Users/shayaan/Downloads/Underlying Cause of Death, 1999-2020 (15).txt",
                 skipfooter=75,sep='\t',engine="python",usecols= [1,3,5,7,9,10,11,12,13])

p4.columns = [c.replace(' ', '_') for c in p4.columns]
p4.columns = [c.replace('-', '_') for c in p4.columns]
p4.drop(p4.index[p4['ICD_10_113_Cause_List'] == "#COVID-19 (U07.1)"], inplace=True)
p4.drop(p4.index[p4['Gender'] == "Male"], inplace=True)

p4.drop(p4.index[p4['Crude_Rate'] == 'Unreliable'], inplace=True)
p4.drop(p4.index[p4['Crude_Rate'] == 'Not Applicable'], inplace=True)
p4['Crude_Rate'] = pd.to_numeric(p4['Crude_Rate'], errors='coerce')
p4['Crude_Rate'] = pd.to_numeric(p4['Age_Adjusted_Rate'], errors='coerce')
p4 = p4.dropna(how="any")

p5 = p4[p4.Race == "White"]
p6 = p4[p4.Race == "Black or African American"]
p5 = pd.merge(p5, p6, on = ["Year","Gender","ICD_10_113_Cause_List"])
p5["unadj_excess_num"] = p5["Deaths_y"] - (p5["Population_y"]*(p5["Deaths_x"]/p5["Population_x"]))
p5["unadj_excess_rate"] = p5["Crude_Rate_y"] - p5["Crude_Rate_x"]
p5["adj_excess_rate"] = p5["Age_Adjusted_Rate_y"] - p5["Age_Adjusted_Rate_x"]

p5 = p5.groupby(["Year","ICD_10_113_Cause_List"]).mean().reset_index()
p5 = p5[["Year","ICD_10_113_Cause_List","adj_excess_rate"]]
p5["Year"] = p5["Year"].astype(int)
p5 = p5.pivot("Year","ICD_10_113_Cause_List","adj_excess_rate")
pd.set_option("display.max_rows", None, "display.max_columns", None)
p5.columns = ["Accidents","Alzheimer's","Assault", "Cerebrovascular Diseases","Conditions From Perinatal Period", "Chronic Liver Disease and Cirrhosis","Chronic Lower Respiratory Diseases","Diabetes","Heart Disease","Hypertension","HIV","Influenza and Pneumonia","Suicide","Cancer","Nephritis","Parkinson's","Pneumonitis due to solids and liquids","Septicemia"]

p5 = p5.transpose()
p5["Most_deaths"] = p5.mean(axis=1)
p5 = p5.sort_values(by = "Most_deaths",ascending = False)
p5 = p5.reindex(["Heart Disease", "Cancer", "Assault", "Cerebrovascular Diseases", "Diabetes", "HIV", "Nephritis", "Septicemia", "Hypertension", "Conditions From Perinatal Period", "Influenza and Pneumonia", "Pneumonitis due to solids and liquids", "Accidents", "Alzheimer's", "Chronic Liver Disease and Cirrhosis", "Parkinson's", "Chronic Lower Respiratory Diseases", "Suicide"])

"""
YPLL Male
"""

p7 = pd.read_csv("/Users/shayaan/Downloads/Underlying Cause of Death, 1999-2020 (14).txt",
                 skipfooter=75,sep='\t',engine="python",usecols= [1,3,5,7,10,11,12,13])


p7.columns = [c.replace(' ', '_') for c in p7.columns]
p7.columns = [c.replace('-', '_') for c in p7.columns]

p7.drop(p7.index[p7['Gender'] == "Female"], inplace=True)
p7.drop(p7.index[p7['Race'] == "American Indian or Alaska Native"], inplace=True)
p7.drop(p7.index[p7['Race'] == "Asian or Pacific Islander"], inplace=True)

p7.drop(p7.index[p7['Five_Year_Age_Groups_Code'] == 'NS'], inplace=True)
p7.drop(p7.index[p7['Crude_Rate'] == 'Unreliable'], inplace=True)
p7.drop(p7.index[p7['Crude_Rate'] == 'Not Applicable'], inplace=True)
p7['Crude_Rate'] = pd.to_numeric(p7['Crude_Rate'], errors='coerce')
p7 = p7.dropna(how="any")

p7["Five_Year_Age_Groups_Code"] = p7["Five_Year_Age_Groups_Code"].str[:2]
p7["Five_Year_Age_Groups_Code"] = p7["Five_Year_Age_Groups_Code"].replace("-","",regex=True)
p7.Five_Year_Age_Groups_Code = pd.to_numeric(p7['Five_Year_Age_Groups_Code'])

p7["age_cat"] = pd.cut(p7.Five_Year_Age_Groups_Code, bins=[0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100], labels = [0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95])
p7.groupby(["Year","age_cat","Gender","Race",]).mean()


p71 = pd.read_csv("/Users/shayaan/Downloads/2022-05-12_code_export/text/file_life_expectancy_1999_to_2020.csv")
p71.rename(columns = {'year':'Year', 'gender':'Gender'}, inplace = True)
p7 = pd.merge(p7, p71, on = ["Year", "age_cat","Gender"])
p7["yrs_lost"] = p7["life_expectancy"]*p7["Crude_Rate"]

p8 = p7[p7.Race == "White"]
p9 = p7[p7.Race == "Black or African American"]
p8 = pd.merge(p8, p9, on = ["Year", "age_cat","Gender","ICD_10_113_Cause_List"])
p8["excess"] = p8["yrs_lost_y"] - p8["yrs_lost_x"]
p8 = p8.groupby(["Year","ICD_10_113_Cause_List"]).mean().reset_index()
p8 = p8[["Year","ICD_10_113_Cause_List","excess"]]
p8["Year"] = p8["Year"].astype(int)
p8 = p8.pivot("Year","ICD_10_113_Cause_List","excess")
pd.set_option("display.max_rows", None, "display.max_columns", None)
p8.columns = ["Accidents","Alzheimer's","Assault", "Cerebrovascular Diseases","Conditions From Perinatal Period", "Chronic Liver Disease and Cirrhosis","Chronic Lower Respiratory Diseases","Diabetes","Heart Disease","Hypertension","HIV","Influenza and Pneumonia","Suicide","Cancer","Nephritis","Parkinson's","Pneumonitis due to solids and liquids","Septicemia"]

p8 = p8.transpose()
p8["Most_deaths"] = p8.mean(axis=1)
p8 = p8.sort_values(by = "Most_deaths",ascending = False)
p8 = p8.drop(labels=("Most_deaths"),axis=1)
p8 = p8.reindex(["Heart Disease", "Cancer", "Assault", "Cerebrovascular Diseases", "Diabetes", "HIV", "Nephritis", "Septicemia", "Hypertension", "Conditions From Perinatal Period", "Influenza and Pneumonia", "Pneumonitis due to solids and liquids", "Accidents", "Alzheimer's", "Chronic Liver Disease and Cirrhosis", "Parkinson's", "Chronic Lower Respiratory Diseases", "Suicide"])

"""
YPLL Female
"""

p10 = pd.read_csv("/Users/shayaan/Downloads/Underlying Cause of Death, 1999-2020 (14).txt",
                 skipfooter=75,sep='\t',engine="python",usecols= [1,3,5,7,10,11,12,13])


p10.columns = [c.replace(' ', '_') for c in p10.columns]
p10.columns = [c.replace('-', '_') for c in p10.columns]

p10.drop(p10.index[p10['Gender'] == "Male"], inplace=True)
p10.drop(p10.index[p10['Race'] == "American Indian or Alaska Native"], inplace=True)
p10.drop(p10.index[p10['Race'] == "Asian or Pacific Islander"], inplace=True)

p10.drop(p10.index[p10['Five_Year_Age_Groups_Code'] == 'NS'], inplace=True)
p10.drop(p10.index[p10['Crude_Rate'] == 'Unreliable'], inplace=True)
p10.drop(p10.index[p10['Crude_Rate'] == 'Not Applicable'], inplace=True)
p10['Crude_Rate'] = pd.to_numeric(p10['Crude_Rate'], errors='coerce')

p10 = p10.dropna(how="any")

p10["Five_Year_Age_Groups_Code"] = p10["Five_Year_Age_Groups_Code"].str[:2]
p10["Five_Year_Age_Groups_Code"] = p10["Five_Year_Age_Groups_Code"].replace("-","",regex=True)
p10.Five_Year_Age_Groups_Code = pd.to_numeric(p10['Five_Year_Age_Groups_Code'])

p10["age_cat"] = pd.cut(p10.Five_Year_Age_Groups_Code, bins=[0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100], labels = [0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95])
p10.groupby(["Year","age_cat","Gender","Race",]).mean()


p101 = pd.read_csv("/Users/shayaan/Downloads/2022-05-12_code_export/text/file_life_expectancy_1999_to_2020.csv")
p101.rename(columns = {'year':'Year', 'gender':'Gender'}, inplace = True)
p10 = pd.merge(p10, p101, on = ["Year", "age_cat","Gender"])
p10["yrs_lost"] = p10["life_expectancy"]*p10["Crude_Rate"]

p11 = p10[p10.Race == "White"]
p12 = p10[p10.Race == "Black or African American"]
p11 = pd.merge(p11, p12, on = ["Year", "age_cat","Gender","ICD_10_113_Cause_List"])
p11["excess"] = p11["yrs_lost_y"] - p11["yrs_lost_x"]
p11 = p11.groupby(["Year","ICD_10_113_Cause_List"]).mean().reset_index()
p11 = p11[["Year","ICD_10_113_Cause_List","excess"]]
p11["Year"] = p11["Year"].astype(int)
p11 = p11.pivot("Year","ICD_10_113_Cause_List","excess")
pd.set_option("display.max_rows", None, "display.max_columns", None)
p11.columns = ["Accidents","Alzheimer's","Assault", "Cerebrovascular Diseases","Conditions From Perinatal Period", "Chronic Liver Disease and Cirrhosis","Chronic Lower Respiratory Diseases","Diabetes","Heart Disease","Hypertension","HIV","Influenza and Pneumonia","Suicide","Cancer","Nephritis","Parkinson's","Pneumonitis due to solids and liquids","Septicemia"]

p11 = p11.transpose()
p11["Most_deaths"] = p11.mean(axis=1)
p11 = p11.sort_values(by = "Most_deaths",ascending = False)
p11 = p11.drop(labels=("Most_deaths"),axis=1)
p11 = p11.reindex(["Heart Disease", "Cancer", "Assault", "Cerebrovascular Diseases", "Diabetes", "HIV", "Nephritis", "Septicemia", "Hypertension", "Conditions From Perinatal Period", "Influenza and Pneumonia", "Pneumonitis due to solids and liquids", "Accidents", "Alzheimer's", "Chronic Liver Disease and Cirrhosis", "Parkinson's", "Chronic Lower Respiratory Diseases", "Suicide"])

"""
plot
"""

f, ((ax1, ax2, axcb), (ax3, ax4, axcb1))  = plt.subplots(2,3,
gridspec_kw={'width_ratios':[1,1,0.08]})

ax1.get_shared_y_axes().join(ax2)
ax3.get_shared_y_axes().join(ax4)

g = sb.heatmap(df2, ax=ax1, cbar = False, center = 0, cmap = "RdBu_r",xticklabels=1, yticklabels=1, vmin=-24,vmax=44, robust = True)
g.set_xticklabels([" "])   
g.set_xlabel(" ")
g.set_ylabel("Cause of Death")
ax1.set_title("Age-Adjusted Excess Death Rate of Black Males \n Compared to White Males Per 100 000 People (1999-2020)",wrap=True)

h = sb.heatmap(p5, ax=ax2, cbar_ax=axcb, center = 0, cmap = "RdBu_r",xticklabels=1, yticklabels=1, vmin=-24,vmax=44)
h.set_xticklabels([" "])
h.set_yticklabels([" "])      
h.set_xlabel(" ")
h.set_ylabel(" ")
ax2.set_title("Age-Adjusted Excess Death Rate of Black Females \n Compared to White Females Per 100 000 People (1999-2020)",wrap=True)

i = sb.heatmap(p8, ax=ax3, center = 0, cbar = False, cmap = "RdBu_r",xticklabels=1, yticklabels=1,vmin = -900, vmax = 2600)
i.set_xlabel("Year")
i.set_ylabel("Cause of Death")
ax3.set_title("Excess Years of Potential Life Lost By Black Males \n Compared to White Males Per 100 000 People (1999-2020)",wrap=True)

j = sb.heatmap(p11, ax=ax4, cbar_ax=axcb1, center = 0, cmap = "RdBu_r",xticklabels=1, yticklabels=1,vmin = -900, vmax = 2600)
j.set_yticklabels([" "])
j.set_xlabel("Year")
ax4.set_title("Excess Years of Potential Life Lost By Black Females \n Compared to White Females Per 100 000 People (1999-2020)",wrap=True)

plt.tight_layout()
plt.show()



















