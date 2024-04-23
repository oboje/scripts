import subprocess
import sys
import os

def create_file_list(files):
    with open("filelist_temp.txt", "w") as f:
        for file in files:
            f.write(f"file '{file}'\n")

def reencode_files(files):
    temp_files = []
    for file in files:
        temp_file = f"{os.path.splitext(file)[0]}_temp.mp4"
        temp_files.append(temp_file)
        try:
            subprocess.run([
                "ffmpeg", "-i", file, 
                "-preset", "ultrafast", 
                "-vf", "scale=1280:-1",
                "-c:v", "libx264", 
                "-c:a", "aac", 
                "-strict", "experimental", temp_file
            ])
        except Exception as e:
            print(f"An error occurred: {e}")
            sys.exit(1)

    return temp_files

def concat_files():
    subprocess.run([
        "ffmpeg", "-f", "concat", "-safe", "0", 
        "-i", "filelist_temp.txt", 
        "-c:v", "copy", "-c:a", "copy", 
        "output.mp4"
    ])

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 merge_videos.py <file1> <file2> ...")
        sys.exit(1)

    input_files = sys.argv[1:]
    temp_files = reencode_files(input_files)

    create_file_list(temp_files)
    concat_files()

    # Remove temporary files
    for temp_file in temp_files:
        os.remove(temp_file)
    os.remove("filelist_temp.txt")

    print("Concatenation and conversion completed.")

if __name__ == "__main__":
    main()
