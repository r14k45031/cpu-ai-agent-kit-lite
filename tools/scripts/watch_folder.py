# -*- coding: utf-8 -*-
"""資料夾監看：把檔案丟進「收件匣」就自動處理，完成後移到「完成」。

規則：文件（PDF/Word/PPT/Excel/txt/md）→ 自動摘要；圖片 → OCR 文字辨識。
資料夾位置：文件\\AI自動處理\\收件匣

用法：雙擊「啟動資料夾監看.bat」（關閉視窗即停止）
測試：watch_folder.py --once（掃一輪就結束）
"""
import shutil
import sys
import time
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import ai_common as ai
import summarize

ROOT = Path.home() / "Documents" / "AI自動處理"
INBOX = ROOT / "收件匣"
DONE = ROOT / "完成"
FAIL = ROOT / "失敗"
LOG = ROOT / "處理紀錄.txt"
SKIP_SUFFIX = ("_摘要", "_OCR", "_解讀", "_改寫", "_就地改寫", "_分析", "_AI處理")


def log(msg):
    line = f"[{datetime.now():%Y-%m-%d %H:%M:%S}] {msg}"
    print(line, flush=True)
    with open(LOG, "a", encoding="utf-8") as fh:
        fh.write(line + "\n")


def safe_move(src, dst_dir):
    dst = dst_dir / src.name
    if dst.exists():
        dst = dst_dir / f"{src.stem}_{datetime.now():%H%M%S}{src.suffix}"
    shutil.move(str(src), str(dst))
    return dst


def handle(f):
    """處理一個檔案，回傳產出的檔案清單。"""
    if f.suffix.lower() in ai.IMAGE_EXTS:
        text = ai.ocr_image_text(f)
        txt = f.with_name(f.stem + "_OCR.txt")
        txt.write_text(text, encoding="utf-8")
        doc = f.with_name(f.stem + "_OCR.docx")
        ai.write_docx(doc, None, text)
        return [txt, doc]
    summarize.process(f)
    out = f.with_name(f.stem + "_摘要.docx")
    return [out] if out.exists() else []


def pending_files():
    for f in sorted(INBOX.iterdir()):
        if (f.is_file() and f.suffix.lower() in summarize.EXTS
                and not f.stem.endswith(SKIP_SUFFIX)):
            yield f


def main():
    once = "--once" in sys.argv
    for d in (INBOX, DONE, FAIL):
        d.mkdir(parents=True, exist_ok=True)
    print("==============================================")
    print("  AI 資料夾監看已啟動（關閉視窗即停止）")
    print(f"  把檔案丟進：{INBOX}")
    print("  文件會自動摘要、圖片會自動 OCR，")
    print(f"  處理完連同結果移到：{DONE}")
    print("==============================================")
    seen = {}
    while True:
        for f in list(pending_files()):
            st = f.stat()
            key = str(f)
            if not once and seen.get(key) != (st.st_size, st.st_mtime):
                seen[key] = (st.st_size, st.st_mtime)  # 等下一輪確認檔案複製完成
                continue
            seen.pop(key, None)
            log(f"處理：{f.name}")
            try:
                outs = handle(f)
                for o in outs:
                    safe_move(o, DONE)
                safe_move(f, DONE)
                log(f"完成：{f.name}（產出 {len(outs)} 個檔案）")
            except Exception as e:
                log(f"失敗：{f.name} — {e}")
                try:
                    safe_move(f, FAIL)
                except OSError:
                    pass
        if once:
            break
        time.sleep(10)


if __name__ == "__main__":
    main()
