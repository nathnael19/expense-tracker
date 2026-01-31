from PIL import Image
import os
import shutil

def process_dark_icon():
    source_icon_path = r'C:\Users\hp\.gemini\antigravity\brain\f6f5d8a7-8c9b-449a-b383-9689ec1a3400\app_icon_dark_1769842639930.png'
    output_icon_path = 'assets/icon/app_icon.png'
    output_foreground_path = 'assets/icon/app_icon_foreground.png'

    try:
        if not os.path.exists(source_icon_path):
            print(f"Error: Source icon not found at {source_icon_path}")
            return

        print(f"Loading {source_icon_path}...")
        img = Image.open(source_icon_path).convert('RGB')
        
        # 1. Update the main app_icon.png
        # We can just copy it directly as the legacy icon.
        img.save(output_icon_path, "PNG")
        print(f"Saved main icon to {output_icon_path}")

        # 2. Extract Background Color (top-left pixel)
        r, g, b = img.getpixel((0, 0))
        hex_color = '#{:02x}{:02x}{:02x}'.format(r, g, b)
        print(f"BACKGROUND_COLOR:{hex_color}") # Output for me to parse
        
        # 3. Create Foreground (transparent background)
        # The prompt said "white abstract wallet or chart symbol".
        # We assume the background is roughly the uniform color sampled.
        # Simple thresholding: if pixel is close to background, make transparent.
        # Otherwise keep it (likely white/light).
        
        foreground = img.convert("RGBA")
        datas = foreground.getdata()
        new_data = []

        # Color distance check
        def is_background(pixel_rgb, bg_rgb, tolerance=30):
            return abs(pixel_rgb[0] - bg_rgb[0]) < tolerance and \
                   abs(pixel_rgb[1] - bg_rgb[1]) < tolerance and \
                   abs(pixel_rgb[2] - bg_rgb[2]) < tolerance

        bg_rgb = (r, g, b)
        
        for item in datas:
            # item is (r,g,b,a)
            if is_background(item[:3], bg_rgb):
                new_data.append((0, 0, 0, 0)) # Fully transparent
            else:
                new_data.append(item)
                
        foreground.putdata(new_data)
        
        # Save foreground
        foreground.save(output_foreground_path, "PNG")
        print(f"Saved foreground to {output_foreground_path}")

    except Exception as e:
        print(f"Error processing icon: {e}")

if __name__ == '__main__':
    process_dark_icon()
