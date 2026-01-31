from PIL import Image

def unify_icons():
    foreground_path = 'assets/icon/app_icon_foreground.png'
    output_path = 'assets/icon/app_icon.png'
    bg_color = (0, 49, 27) # #00311b converted to RGB
    
    try:
        print(f"Loading foreground from {foreground_path}...")
        fg = Image.open(foreground_path).convert("RGBA")
        
        # Create new background image
        # Standard icon size usually 1024x1024 or 512x512
        # Use dimensions of foreground
        bg = Image.new("RGBA", fg.size, bg_color + (255,))
        
        # Composite
        # Since fg has transparency, we paste it over bg using itself as mask
        bg.paste(fg, (0, 0), fg)
        
        # Save as app_icon.png
        bg.save(output_path)
        print(f"Saved unified icon to {output_path}")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    unify_icons()
