import sys
import win32com.client

def walk_shapes(shapes, out_lines, depth=0):
    """Recursively extract text from shapes."""
    for sh in shapes:
        try:
            if sh.Type == 6:  # group
                walk_shapes(sh.GroupItems, out_lines, depth)
                continue
            if sh.HasTextFrame:
                t = sh.TextFrame.TextRange.Text
                if t and t.strip():
                    out_lines.append(t)
        except Exception:
            pass

def extract(pptx_path):
    app = win32com.client.Dispatch("PowerPoint.Application")
    pres = app.Presentations.Open(pptx_path, ReadOnly=True, WithWindow=False)
    slides = pres.Slides
    print(f"=== FILE: {pptx_path} ===")
    print(f"Slides: {slides.Count}")
    for i in range(1, slides.Count + 1):
        slide = slides(i)
        out_lines = []
        walk_shapes(slide.Shapes, out_lines)
        # notes
        notes = ""
        try:
            if slide.NotesPage.Shapes.HasTextFrame and slide.NotesPage.Shapes.TextFrame.TextRange.Text.strip():
                notes = slide.NotesPage.Shapes.TextFrame.TextRange.Text
        except Exception:
            pass
        print(f"\n--- Slide {i} ---")
        for line in out_lines:
            print(repr(line))
        if notes:
            print(f"[NOTES]: {notes}")
    pres.Close()
    app.Quit()

if __name__ == "__main__":
    extract(sys.argv[1])
