import os
import re

def migrate_colors(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace withOpacity(x) with withValues(alpha: x)
                new_content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
                
                if new_content != content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Migrated: {path}")

if __name__ == "__main__":
    migrate_colors('d:/Projects/skillmatch/skillmatch_app/lib')
