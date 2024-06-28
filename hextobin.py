def hextobin(hex_text):
    bin_text = ''
    for hex_char in hex_text:
        if hex_char.isalnum():
            bin_text += bin(int(hex_char, 16))[2:].zfill(4)
    
    return bin_text

def convert_hex_file_to_bin(input_filename, output_filename):
    with open(input_filename, 'r') as hex_file:
        hex_content = hex_file.read()
    # hex_content = hex_content.replace('\n', '')
    hex_content = hex_content.replace(' ', '')

    bin_content = hextobin(hex_content)

    with open(output_filename, 'w') as bin_file:
        for i in range(0, len(bin_content), 8):
            bin_file.write(bin_content[i:i+8] + '\n')

convert_hex_file_to_bin('./SampleTestcase/call_ret_simple.txt', './SampleTestcase/call_ret_simple.txt')

    
