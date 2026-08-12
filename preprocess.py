import csv

input_file = "dataset/chicago_crimes_10k.csv"
output_file = "dataset/chicago_crimes_clean.csv"

with open(input_file, 'r', newline='') as infile, open(output_file, 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile, quoting=csv.QUOTE_MINIMAL)
    
    for row in reader:
        # Replace newlines in each field with a space
        cleaned_row = [field.replace('\n', ' ').replace('\r', '') for field in row]
        writer.writerow(cleaned_row)

print("Preprocessing complete. Cleaned file saved to:", output_file)
