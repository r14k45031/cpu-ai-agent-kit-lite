# -*- coding: utf-8 -*-
"""AI 改寫／潤稿：讀入 Word 或文字檔，依指示改寫後輸出新的 Word 檔。

用法：polish_docx.py <檔案路徑>（執行時會詢問改寫指示）
輸出：<原檔名>_改寫.docx
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import ai_common as ai

DEFAULT = "潤稿：使語句通順、專業、簡潔，修正錯字與贅詞，保留原意與段落結構"


def main():
    if len(sys.argv) < 2:
        raise SystemExit("用法：把 .docx / .txt / .md 拖到「拖入Word改寫.bat」上")
    f = Path(sys.argv[1])
    if f.suffix.lower() not in (".docx", ".txt", ".md"):
        raise SystemExit("請拖入 .docx / .txt / .md 檔案")
    try:
        instr = input(f"要怎麼改寫？（直接按 Enter ＝ {DEFAULT}）\n> ").strip()
    except EOFError:
        instr = ""
    instr = instr or DEFAULT
    print(f"讀取：{f.name}（模型：{ai.pick_model()}）")
    text = ai.read_document(f)
    if not text.strip():
        raise SystemExit("檔案內容是空的。")
    chunks = ai.chunk_text(text)
    results = []
    for i, c in enumerate(chunks, 1):
        if len(chunks) > 1:
            print(f"  改寫第 {i}/{len(chunks)} 段...")
        results.append(ai.chat(
            "請依照以下指示改寫文字，只輸出改寫後的結果，"
            f"不要加任何說明或開場白。\n指示：{instr}\n\n---\n{c}"
        ))
    out = f.with_name(f.stem + "_改寫.docx")
    ai.write_docx(out, None, "\n\n".join(results))
    print(f"已輸出：{out.name}")


if __name__ == "__main__":
    main()
