# -*- coding: utf-8 -*-
"""掃描 PDF 或圖片（PNG/JPG/TIF/BMP）的 OCR 文字辨識（繁體中文＋英文）。

用法：ocr_pdf.py <PDF 或圖片路徑>
輸出：<原檔名>_OCR.txt 與 <原檔名>_OCR.docx
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import ai_common as ai


def main():
    if len(sys.argv) < 2:
        raise SystemExit("用法：把 PDF 或圖片拖到「拖入PDF或圖片做OCR.bat」上")
    f = Path(sys.argv[1])
    ext = f.suffix.lower()
    print(f"開始 OCR：{f.name}")
    if ext == ".pdf":
        text = ai.ocr_pdf_text(f)
    elif ext in ai.IMAGE_EXTS:
        text = ai.ocr_image_text(f)
    else:
        raise SystemExit("請拖入 .pdf 或圖片檔（png / jpg / tif / bmp）")
    txt = f.with_name(f.stem + "_OCR.txt")
    txt.write_text(text, encoding="utf-8")
    doc = f.with_name(f.stem + "_OCR.docx")
    ai.write_docx(doc, None, text)
    print(f"完成，已輸出：{txt.name}、{doc.name}")


if __name__ == "__main__":
    main()
