from rembg import remove
from PIL import Image
import os
import json

def process_icon():
    input_path = 'assets/icon/app_icon.png'
    output_path = 'assets/icon/app_icon_foreground.png'
    
    try:
        # Load the image
        print(f"Loading {input_path}...")
        input_image = Image.open(input_path)
        
        # Get the dominant color from the corners (background)
        # We'll sample 4 corners and the center of edges to avoid symbol
        corners = [
            (0, 0), 
            (input_image.width - 1, 0), 
            (0, input_image.height - 1), 
            (input_image.width - 1, input_image.height - 1)
        ]
        
        r_sum, g_sum, b_sum = 0, 0, 0
        count = 0
        
        rgb_im = input_image.convert('RGB')
        
        for x, y in corners:
            r, g, b = rgb_im.getpixel((x, y))
            r_sum += r; g_sum += g; b_sum += b
            count += 1
            
        avg_r = int(r_sum / count)
        avg_g = int(g_sum / count)
        avg_b = int(b_sum / count)
        
        hex_color = '#{:02x}{:02x}{:02x}'.format(avg_r, avg_g, avg_b)
        print(f"Estimated Background Color: {hex_color}")
        
        # Remove background
        print(" removing background...")
        output_image = remove(input_image)
        
        # Save foreground
        output_image.save(output_path)
        print(f"Saved foreground to {output_path}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    process_icon()
