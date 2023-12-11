loglist = ["google_0_5_5_3.log", "google_0_5_10_3.log", "google_0_5_25_3.log", "google_0_10_5_3.log", "google_0_10_10_3.log", "google_0_10_25_3.log", ]
for file_path in loglist:
    file_path_new = 'mod'+file_path
    x = 300  # Replacewith your desired threshold
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()

        updated_lines = []
        for line in lines:
            updated_line = ' '.join(word for word in line.split() if not word.isdigit() or int(word) <= x)
            updated_lines.append(updated_line)

        with open(file_path_new, 'w') as file:
            file.write('\n'.join(updated_lines))

        print(f"Numbers greater than {x} removed from the file '{file_path}'.")

    except FileNotFoundError:
        print(f"File '{file_path}' not found.")

# Usage example
