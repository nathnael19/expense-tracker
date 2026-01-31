from PIL import Image
import os

def process_icon_fast():
    original_icon_path = 'assets/icon/app_icon.png'
    # Use the absolute path or just try to find it if I know where I saved it. 
    # Wait, I saved 'app_icon_symbol_only_1769843200204.png' to artifacts dir.
    # I need to copy it or reference it.
    # The artifact path is C:\Users\hp\.gemini\antigravity\brain\f6f5d8a7-8c9b-449a-b383-9689ec1a3400\app_icon_symbol_only_1769843200204.png
    symbol_path = r'C:\Users\hp\.gemini\antigravity\brain\f6f5d8a7-8c9b-449a-b383-9689ec1a3400\app_icon_symbol_only_1769843200204.png'
    output_foreground_path = 'assets/icon/app_icon_foreground.png'
    
    try:
        # 1. Get Background Color from Original
        print(f"Sampling color from {original_icon_path}...")
        original = Image.open(original_icon_path).convert('RGB')
        # Sample top-left pixel
        r, g, b = original.getpixel((0, 0))
        hex_color = '#{:02x}{:02x}{:02x}'.format(r, g, b)
        print(f"BACKGROUND_COLOR:{hex_color}") # Output for me to parse
        
        # 2. Process Symbol to create Transparent Foreground
        print(f"Processing symbol from {symbol_path}...")
        symbol_img = Image.open(symbol_path).convert("RGBA")
        
        datas = symbol_img.getdata()
        new_data = []
        
        # Simple threshold to remove white background
        threshold = 240
        for item in datas:
            # item is (r,g,b,a)
            if item[0] > threshold and item[1] > threshold and item[2] > threshold:
                new_data.append((255, 255, 255, 0)) # Transparent
            else:
                new_data.append(item)
                
        symbol_img.putdata(new_data)
        
        # Resize to ensuring it fits well. 
        # Adaptive icons are 108x108 dp, visible area is 72dp diameter mask.
        # So content should be centered.
        # The generated image is likely already centered.
        
        symbol_img.save(output_foreground_path, "PNG")
        print(f"Saved foreground to {output_foreground_path}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    process_icon_fast()
