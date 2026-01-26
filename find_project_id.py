
import json
import codecs

try:
    # Try reading as utf-8 first (standard), then utf-16
    try:
        with open('firebase_list.json', 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        with open('firebase_list.json', 'r', encoding='utf-16') as f:
            content = f.read()

    # The file might contain non-JSON junk at the beginning (spinners)
    # Find the first '[' and last ']'
    start = content.find('[')
    end = content.rfind(']') + 1
    
    if start != -1 and end != -1:
        json_content = content[start:end]
        projects = json.loads(json_content)
        
        for p in projects:
            if 'expense-tracker' in p.get('projectId', '') or 'expense-tracker' in p.get('displayName', ''):
                print(f"FOUND: {p['projectId']}")
    else:
        print("Could not find JSON list in file")

except Exception as e:
    print(f"Error: {e}")
