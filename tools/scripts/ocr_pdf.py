# -*- coding: utf-8 -*-
"""掃描 PDF 的 OCR 文字辨識（繁體中文＋英文）。

用法：ocr_pdf.py <PDF 路徑>
輸出：<原檔名>_OCR.txt 與 <原檔名>_OCR.docx
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import ai_common as ai


def main():
    if len(sys.argv) < 2:
        raise SystemExit("用法：把 PDF 拖到「拖入PDF做OCR.bat」上")
    f = Path(sys.argv[1])
    if f.suffix.lower() != ".pdf":
        raise SystemExit("請拖入 .pdf 檔案")
    print(f"開始 OCR：{f.name}")
    text = ai.ocr_pdf_text(f)
    txt = f.with_name(f.stem + "_OCR.txt")
    txt.write_text(text, encoding="utf-8")
    doc = f.with_name(f.stem + "_OCR.docx")
    ai.write_docx(doc, None, text)
    print(f"完成，已輸出：{txt.name}、{doc.name}")


if __name__ == "__main__":
    main()
