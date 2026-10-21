import subprocess, os

build = r"D:\魏舟\工程软件\.oleafly\linked\linked-87ff8f1189a07551e1dcbfcd81e21ed8\build"
pdf = os.path.join(build, "_oleafly_entry.pdf")

def run(args):
    r = subprocess.run(args, capture_output=True)
    return r.stdout.decode("utf-8", "replace") + r.stderr.decode("utf-8", "replace")

print("=== pdffonts (after switch) ===")
print(run(["pdffonts", pdf]))

print("=== pdftotext page 2 (should contain 序/正文) ===")
print(run(["pdftotext", "-enc", "UTF-8", "-f", "2", "-l", "2", pdf, "-"])[:900])
