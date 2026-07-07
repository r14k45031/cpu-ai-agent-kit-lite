# -*- coding: utf-8 -*-
"""批次摘要：把檔案（或整個資料夾的 PDF/Word/文字檔）各自摘要成一份 Word。

用法：summarize.py <檔案或資料夾路徑>
輸出：與原檔同資料夾的 <原檔名>_摘要.docx
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import ai_common as ai

EXTS = {".pdf", ".docx", ".pptx", ".xlsx", ".txt", ".md",
        ".png", ".jpg", ".jpeg", ".bmp", ".tif", ".tiff"}


def summarize_text(text):
    chunks = ai.chunk_text(text)
    if len(chunks) == 1:
        return ai.chat(
            "請為以下文件寫一份結構化的繁體中文摘要：先一段總覽，"
            "再條列重點（最多 8 點）。只輸出摘要本身，不要加開場白。\n\n---\n" + chunks[0]
        )
    partials = []
    for i, c in enumerate(chunks, 1):
        print(f"  摘要第 {i}/{len(chunks)} 段...")
        partials.append(ai.chat("請用繁體中文條列以下文件片段的重點：\n\n" + c))
    print("  整合各段摘要...")
    return ai.chat(
        "以下是同一份文件各段落的重點整理，請整合成一份完整、不重複的繁體中文摘要"
        "（先一段總覽，再條列重點）。只輸出摘要本身。\n\n" + "\n\n".join(partials)
    )


def process(f):
    print(f"處理：{f.name}")
    text = ai.read_document(f)
    if len(text.strip()) < 40:
        print("  擷取不到足夠文字（可能是掃描檔且未裝 OCR），跳過。")
        return
    summary = summarize_text(text)
    out = f.with_name(f.stem + "_摘要.docx")
    ai.write_docx(out, f.stem + " — 摘要", summary)
    print(f"  已輸出：{out.name}")


def main():
    if len(sys.argv) < 2:
        raise SystemExit("用法：把檔案或整個資料夾拖到「拖入文件做摘要.bat」上")
    target = Path(sys.argv[1])
    if target.is_file():
        files = [target]
    else:
        files = sorted(
            p for p in target.iterdir()
            if p.suffix.lower() in EXTS and not p.stem.endswith(("_摘要", "_改寫", "_OCR"))
        )
    if not files:
        raise SystemExit("找不到可處理的檔案（支援 .pdf / .docx / .txt / .md）")
    print(f"共 {len(files)} 個檔案，使用模型：{ai.pick_model()}")
    for f in files:
        try:
            process(f)
        except Exception as e:
            print(f"  處理失敗：{e}")
    print("全部完成。")


if __name__ == "__main__":
    main()
