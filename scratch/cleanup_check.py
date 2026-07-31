import os, glob

lib_dir = r"d:\ohara works\ResumeAI_Pro\resume_ai_clean\lib"
print_count = 0
todo_count = 0

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                for idx, line in enumerate(lines, 1):
                    if 'print(' in line and not line.strip().startswith('//'):
                        print_count += 1
                        print(f"PRINT in {file}:{idx}: {line.strip()}")
                    if 'TODO' in line and not line.strip().startswith('//'):
                        todo_count += 1
                        print(f"TODO in {file}:{idx}: {line.strip()}")

print(f"\nTotal print statements found: {print_count}")
print(f"Total TODO items found: {todo_count}")
