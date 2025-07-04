#!/usr/bin/env python3

import sys
import re
import os

if len(sys.argv) != 2:
    print("Please provide the file path of the GFF annotation as the first argument.")
    sys.exit(1)

# Get the input file name from command-line argument
file = sys.argv[1]
# Give a new name for the output file:
output_file = os.path.splitext(file)[0] + "_fix.gff3"

with open(file, 'r') as input_file:
    with open(output_file, "w") as output_file:
        counter = 0
        for line in input_file:
            # Print header:
            if line.startswith("#"):
                output_file.write(line)

            else:
                # Search for the ID column in the GFF
                columns = line.split('\t')
                column_9 = columns[8].strip()
                # If ID=repeat_region ....
                pattern1 = r"ID=repeat_region_[0-9]+"
                pattern2 = r"Parent=repeat_region_[0-9]+"
                if re.search(pattern1, column_9.split(';')[0]):
                    counter += 1
                    ID_pattern = r"repeat_region_[0-9]+"
                    new_line, _ = re.subn(ID_pattern, f"repeat_region_{counter}", line)
                    # Write to the output file
                    output_file.write(new_line)
                # If Parent=repeat_region.....
                elif re.search(pattern2, column_9.split(';')[1]):
                    # Main change
                    ID_pattern = r"repeat_region_[0-9]+"
                    new_line, _ = re.subn(ID_pattern, f"repeat_region_{counter}", line)
                    #  other changes:
                    ID_pattern = r"ID=lLTR_[0-9]+"
                    new_line, _ = re.subn(ID_pattern, f"ID=lLTR_{counter}", new_line)
                    ID_pattern = r"ID=LTRRT_[0-9]+"
                    new_line, _ = re.subn(ID_pattern, f"ID=LTRRT_{counter}", new_line)
                    ID_pattern = r"ID=lTSD_[0-9]+"
                    new_line, _ = re.subn(ID_pattern, f"ID=lTSD_{counter}", new_line)
                    ID_pattern = r"ID=rLTR_[0-9]+"
                    new_line, _ = re.subn(ID_pattern, f"ID=rLTR_{counter}", new_line)
                    ID_pattern = r"ID=rTSD_[0-9]+"
                    new_line, _ = re.subn(ID_pattern, f"ID=rTSD_{counter}", new_line)
                    # Write to the output file
                    output_file.write(new_line)
                else:
                    output_file.write(line)
