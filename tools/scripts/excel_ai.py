# -*- coding: utf-8 -*-
"""Excel AI 分析：拖入試算表，自動產出分析報告，或直接問資料問題。

用法：excel_ai.py <xlsx/csv 路徑>（執行時會詢問想問什麼）
輸出：<原檔名>_分析.docx，並同時顯示在畫面上
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import ai_common as ai

DEFAULT = ("請產出一份資料分析報告：1) 資料概況（有哪些欄位、多少筆）"
           " 2) 關鍵數字 3) 明顯的趨勢或異常 4) 給管理者的三點建議")


def basic_stats(path):
    """對數值欄位算基本統計，補足小模型的算術弱點。"""
    import openpyxl

    wb = openpyxl.load_workbook(str(path), read_only=True, data_only=True)
    lines = []
    for ws in wb.worksheets:
        rows = ws.iter_rows(values_only=True)
        header = next(rows, None)
        if not header:
            continue
        cols = {i: [] for i in range(len(header))}
        for row in rows:
            for i, v in enumerate(row):
                if isinstance(v, (int, float)) and i in cols:
                    cols[i].append(v)
        for i, vals in cols.items():
            if len(vals) >= 3:
                name = header[i] if header[i] is not None else f"第{i+1}欄"
                lines.append(
                    f"{ws.title}/{name}：筆數 {len(vals)}、總和 {sum(vals):,.2f}、"
                    f"平均 {sum(vals)/len(vals):,.2f}、最小 {min(vals):,.2f}、最大 {max(vals):,.2f}"
                )
    wb.close()
    return "\n".join(lines)


def main():
    if len(sys.argv) < 2:
        raise SystemExit("用法：把 .xlsx / .csv 拖到「拖入Excel分析.bat」上")
    f = Path(sys.argv[1])
    ext = f.suffix.lower()
    if ext not in (".xlsx", ".xlsm", ".csv"):
        raise SystemExit("請拖入 .xlsx / .xlsm / .csv 檔案")
    try:
        q = input("想問這份資料什麼？（直接按 Enter ＝ 自動產出分析報告）\n> ").strip()
    except EOFError:
        q = ""
    q = q or DEFAULT

    print(f"讀取：{f.name}（模型：{ai.pick_model()}）")
    data_text = ai.read_document(f)
    stats = basic_stats(f) if ext != ".csv" else ""
    prompt = f"以下是一份試算表的內容：\n\n{data_text}\n"
    if stats:
        prompt += f"\n（程式已算好的精確統計，回答數字時請以此為準：\n{stats}）\n"
    prompt += f"\n{q}\n請用繁體中文（台灣用語）回答。"

    answer = ai.chat(prompt)
    print()
    print(answer)
    out = f.with_name(f.stem + "_分析.docx")
    ai.write_docx(out, f.name + " — AI 分析", "問題:" + q + "\n\n" + answer)
    print(f"\n已輸出:{out.name}")


if __name__ == "__main__":
    main()
