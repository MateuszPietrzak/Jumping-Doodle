def hex_to_rgb555(hex_color):
    # Ensure the hex color starts with '#'
    if not hex_color.startswith('#'):
        hex_color = '#' + hex_color

    # Convert the hex color to decimal RGB values
    r = int(hex_color[1:3], 16)
    g = int(hex_color[3:5], 16)
    b = int(hex_color[5:7], 16)

    # Clamp the RGB values to 5 bits
    r = r >> 3
    g = g >> 3
    b = b >> 3

    print(r,g,b)

    # Combine the RGB values into a single 16-bit value
    rgb555 = (b << 10) | (g << 5) | r

    # Convert the RGB555 color value to binary and pad with zeros
    rgb555_binary = bin(rgb555)[2:].zfill(16)

    return rgb555_binary

hex_color = input("Enter a hex color value (RRGGBB): ")
rgb555_color = hex_to_rgb555(hex_color)
print(f"The RGB555 color value in binary is\n; GGGRRRRR\ndb %{rgb555_color[8:16]}\n; XBBBBBGG\ndb %{rgb555_color[0:8]}")
