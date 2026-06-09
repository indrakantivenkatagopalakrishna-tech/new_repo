import os
import base64

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
    "{{TEMPLE_DEITY}}": "temple_deity.jpg"
}

def get_base64_data_uri(filename):
    filepath = os.path.join(photos_dir, filename)
    if not os.path.exists(filepath):
        print(f"Warning: File {filename} not found at {filepath}")
        return ""
    
    with open(filepath, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode("utf-8")
        return f"data:image/jpeg;base64,{encoded_string}"

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
        
    print(f"\nCompilation finished!")
    print(f"Total replacements made: {replacements_made}")
    print(f"Self-contained website compiled successfully to: {output_path}")
    print(f"Compiled file size: {os.path.getsize(output_path) / (1024 * 1024):.2f} MB")

if __name__ == "__main__":
    main()
