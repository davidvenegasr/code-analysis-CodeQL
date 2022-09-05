import csv
import glob
import os
import shutil
import pandas as pd

df = pd.read_csv("hash.csv")

for index, row in df.iterrows():
    print(row['c1'], row['c2'])


# src_folder = r"C:\Users\david\Documents\Pasantia\analisis de resultados\testcode\\"
# dst_folder = r"C:\Users\david\Documents\Pasantia\analisis de resultados\testHash\\

# # Search files with .txt extension in source directory
# pattern = f"{}"
# files = glob.glob(src_folder + pattern)

# # move the files with txt extension
# for file in files:
#     # extract file name form file path
#     file_name = os.path.basename(file)
#     shutil.move(file, dst_folder + file_name)
#     print('Moved:', file)
        