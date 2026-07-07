# -*- coding: utf-8 -*-
"""AI 圖片解讀：用視覺模型看懂圖片內容（描述、讀圖表、回答問題）。

用法：describe_image.py <圖片路徑>（執行時會詢問你想問什麼）
輸出：<原檔名>_解讀.docx，並同時顯示在畫面上
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import ai_common as ai

DEFAULT = "請詳細描述這張圖片的內容；若圖中有文字，請完整列出。"


def main():
    if len(sys.argv) < 2:
        raise SystemExit("用法：把圖片拖到「拖入圖片AI解讀.bat」上")
    f = Path(sys.argv[1])
    if f.suffix.lower() not in ai.IMAGE_EXTS:
        raise SystemExit("請拖入圖片檔（png / jpg / tif / bmp）")
    model = ai.pick_vision_model()
    try:
        q = input(f"想問這張圖什麼？（直接按 Enter ＝ {DEFAULT}）\n> ").strip()
    except EOFError:
        q = ""
    q = q or DEFAULT
    print(f"解讀中：{f.name}（模型：{model}，純 CPU 讀圖需要一點時間）...")
    answer = ai.chat(q + "\n請使用繁體中文（台灣用語）回答。", image_path=f)
    print()
    print(answer)
    out = f.with_name(f.stem + "_解讀.docx")
    ai.write_docx(out, f.name + " — AI 解讀", "問題:" + q + "\n\n" + answer)
    print(f"\n已輸出：{out.name}")


if __name__ == "__main__":
    main()
