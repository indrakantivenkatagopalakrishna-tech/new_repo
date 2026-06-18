import os
import base64
import io
from PIL import Image

# Define paths
workspace_dir = os.path.dirname(os.path.abspath(__file__))
photos_dir = os.path.join(workspace_dir, "photos_compressed")
template_path = os.path.join(workspace_dir, "template.html")
output_path = os.path.join(workspace_dir, "index.html")

# Image mappings for Advanced v2
image_mappings = {
    "{{NEW_MAIN_PORTRAIT}}": "new_main_portrait.jpg",
    "{{ABOUT_PORTRAIT}}": "WhatsApp Image 2026-06-06 at 4.58.56 PM.jpeg",
    "{{CERT_DOCTORATE}}": "WhatsApp Image 2026-06-09 at 6.32.45 PM.jpeg",
    "{{CERT_TELUGU_FELICITATION}}": "WhatsApp Image 2026-06-06 at 4.08.07 PM.jpeg",
    "{{CERT_ANNAVARAM}}": "WhatsApp Image 2026-06-06 at 4.58.49 PM.jpeg",
    "{{CERT_TIRUPATI}}": "WhatsApp Image 2026-06-06 at 4.58.50 PM (1).jpeg",
    "{{CERT_TELUGU_UNIV}}": "WhatsApp Image 2026-06-06 at 4.58.48 PM.jpeg",
    "{{TEMPLE_HANDOVER_1}}": "temple_handover_1.jpg",
    "{{TEMPLE_HANDOVER_2}}": "temple_handover_2.jpg",
    "{{TEMPLE_EXTERIOR}}": "temple_exterior.jpg",
    "{{TEMPLE_DEITY}}": "temple_deity.jpg",
    "{{FAVICON}}": "favicon.jpg"
}

def get_base64_data_uri(filename):
    filepath = os.path.join(photos_dir, filename)
    if not os.path.exists(filepath):
        # Fallback to photos dir
        filepath = os.path.join(workspace_dir, "photos", filename)
        if not os.path.exists(filepath):
            print(f"Warning: File {filename} not found at {filepath}")
            return ""
    
    try:
        with Image.open(filepath) as img:
            # Check if this is a certificate/text image or general photo
            is_cert = "CERT" in filename or "WhatsApp Image" in filename
            
            # Setup conversion and compression parameters
            # Certificate images (text-heavy) quality 75-80, other photos quality 70
            quality = 75 if is_cert else 70
            
            # If color space is RGBA or palette, convert to RGB
            if img.mode in ("RGBA", "P"):
                img = img.convert("RGB")
            
            # Resize if the image is extremely large to keep base64 payload minimal
            is_favicon = "favicon" in filename.lower()
            if is_favicon:
                img = img.resize((96, 96), Image.Resampling.LANCZOS)
                print(f"  Resized favicon {filename} to 96x96")
            else:
                max_width = 1600 if is_cert else 1000
                if img.width > max_width:
                    aspect_ratio = img.height / img.width
                    new_width = max_width
                    new_height = int(new_width * aspect_ratio)
                    img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                    print(f"  Resized {filename} to {new_width}x{new_height}")
                
            output_buffer = io.BytesIO()
            img.save(output_buffer, format="WEBP", quality=quality, method=4)
            webp_data = output_buffer.getvalue()
            
            encoded_string = base64.b64encode(webp_data).decode("utf-8")
            print(f"  Converted {filename} to WebP on-the-fly. Size: {len(webp_data)/1024:.1f} KB")
            return f"data:image/webp;base64,{encoded_string}"
            
    except Exception as e:
        print(f"Error converting {filename} to WebP: {e}. Falling back to source file...")
        with open(filepath, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode("utf-8")
            ext = os.path.splitext(filename)[1].lower().replace(".", "")
            if ext == "jpg":
                ext = "jpeg"
            return f"data:image/{ext};base64,{encoded_string}"

def main():
    print("Starting compilation of Advanced Cosmic Vedic Website (v2)...")
    
    # 1. Read the template
    if not os.path.exists(template_path):
        print(f"Error: Template file not found at {template_path}")
        return
        
    with open(template_path, "r", encoding="utf-8") as f:
        html_content = f.read()
    
    # 2. Replace placeholders with base64 URIs
    replacements_made = 0
    for placeholder, filename in image_mappings.items():
        print(f"Encoding {filename} for {placeholder}...")
        base64_uri = get_base64_data_uri(filename)
        
        if base64_uri:
            # Replace occurrences
            old_len = len(html_content)
            html_content = html_content.replace(placeholder, base64_uri)
            new_len = len(html_content)
            if new_len != old_len:
                replacements_made += 1
                print(f"Successfully replaced {placeholder}.")
            else:
                print(f"Warning: Placeholder {placeholder} was not found in template.html.")
        else:
            print(f"Error: Failed to obtain base64 for {filename}")
            
    # 3. Write compiled file
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(html_content)
        
    # 4. Generate physical favicon files for search engines / fallbacks
    favicon_src = os.path.join(workspace_dir, "photos", "favicon.jpg")
    if os.path.exists(favicon_src):
        try:
            with Image.open(favicon_src) as img:
                if img.mode in ("RGBA", "P"):
                    img = img.convert("RGB")
                
                # Save favicon.png (96x96)
                png_path = os.path.join(workspace_dir, "favicon.png")
                img_png = img.resize((96, 96), Image.Resampling.LANCZOS)
                img_png.save(png_path, format="PNG")
                print(f"Generated physical {png_path} (96x96)")

                # Save favicon.ico (containing 16x16, 32x32, 48x48)
                ico_path = os.path.join(workspace_dir, "favicon.ico")
                img.save(ico_path, format="ICO", sizes=[(16, 16), (32, 32), (48, 48)])
                print(f"Generated physical {ico_path} (multi-size)")
        except Exception as e:
            print(f"Error generating physical favicon files: {e}")
        
    print(f"\nCompilation finished!")
    print(f"Total replacements made: {replacements_made}")
    print(f"Self-contained website compiled successfully to: {output_path}")
    print(f"Compiled file size: {os.path.getsize(output_path) / (1024 * 1024):.2f} MB")

if __name__ == "__main__":
    main()
