# 純 CPU 地端 AI 文書 Agent — 離線安裝包（輕量版）

不需要網路、不需要 GPU 的本機 AI 文書處理系統。
輕量版使用 **Qwen3-4B** 模型，**8 GB 記憶體的舊電腦、筆電都能跑**，
總下載量只有約 5 GB。

> 電腦有 32 GB 記憶體？請改用
> [完整版 cpu-ai-agent-kit-full](https://github.com/r14k45031/cpu-ai-agent-kit-full)，
> 內含品質好得多的 30B 主力模型。

安裝後可以做的事：

- 摘要、潤稿、改寫、中英翻譯、草擬公文與商務文件
- 把 Word / PDF 丟進知識庫，針對內容問答（RAG）
- 掃描型 PDF 的 OCR 文字辨識（繁體中文＋英文）
- 批次處理：整個資料夾的文件一鍵各自摘要成 Word
- AI 產出的內容一鍵轉成 .docx

**所有資料都留在目標電腦本機，不會外傳。**

> 安裝完成後的詳細操作教學（AnythingLLM 逐步設定、提示詞範例、
> 各工具用法、調校與疑難排解）請看 **[使用說明.md](使用說明.md)**。

---

## 使用流程（兩階段）

GitHub 放不下模型與安裝程式（單檔上限 100 MB），所以分成兩步：

```
┌─ 有網路的電腦 ──────────────────┐      ┌─ 離線目標電腦 ────────────┐
│ 1. git clone 本倉庫（或下載 ZIP）│      │ 4. 雙擊 install.bat       │
│ 2. 雙擊 download.bat（約 5 GB）  │ ─►   │ 5. 開始使用               │
│ 3. 整個資料夾複製到隨身碟        │ USB  │                          │
└─────────────────────────────────┘      └──────────────────────────┘
```

`download.bat` 中斷後重新執行會自動斷點續傳。

## 目標電腦系統需求

| 項目 | 需求 |
|---|---|
| 作業系統 | Windows 10 / 11，64 位元 |
| 記憶體 | 8 GB 以上 |
| 磁碟空間 | C 槽至少 15 GB |
| 顯示卡 | 不需要，純 CPU 執行 |
| 網路 | 不需要，全程離線 |
| 權限 | 安裝 Tesseract OCR 時會跳一次「使用者帳戶控制」視窗，按「是」即可 |

## download.bat 會下載什麼

| 檔案 | 用途 | 大小 |
|---|---|---|
| OllamaSetup.exe | 推論引擎 | 約 1.4 GB |
| AnythingLLMDesktop.exe | 圖形介面＋文件知識庫（RAG） | 395 MB |
| pandoc / Tesseract（含繁中）/ Python＋離線套件 | 轉檔、OCR、自動化 | 約 220 MB |
| Qwen3-4B-Instruct-2507 Q4_K_M | 對話模型 | 2.5 GB |
| bge-m3 Q8_0 | 向量嵌入（知識庫檢索） | 0.6 GB |

模型來源：Hugging Face（unsloth/Qwen3-4B-Instruct-2507-GGUF、gpustack/bge-m3-GGUF）。

---

## 安裝完成後的使用方式

### 方式一：AnythingLLM（對話＋文件問答）

1. 從開始選單開啟 **AnythingLLM**。
2. LLM 供應商選 **Ollama**（位址 `http://127.0.0.1:11434`），模型選 `qwen3-4b`。
3. 設定 → Embedder 選 Ollama 的 `bge-m3`。
4. 建立工作區，把 Word / PDF 拖進去，就能針對內容問答、摘要、改寫。

### 方式二：tools 資料夾的拖放工具

| 工具 | 用法 | 輸出 |
|---|---|---|
| 拖入文件做摘要.bat | 拖一個檔案**或整個資料夾**上去 | 每份文件旁產生 `_摘要.docx` |
| 拖入PDF做OCR.bat | 拖掃描型 PDF 上去 | `_OCR.txt` 與 `_OCR.docx` |
| 拖入Word改寫.bat | 拖 docx/txt 上去，輸入指示（Enter＝潤稿） | `_改寫.docx` |
| 拖入MD轉Word.bat | 拖 AI 產出的 .md/.txt 上去 | 同名 `.docx` |

- 摘要工具遇到沒有文字層的掃描 PDF 會自動先 OCR 再摘要。
- 想調整提示詞，直接編輯 `tools/scripts/` 裡的 Python 檔。

### 能力邊界（誠實聲明）

- **能做**：讀取 docx/PDF 內容、AI 產生或改寫全文、輸出成排版乾淨的新 Word 檔。
- **做不到**：在排版複雜的原始 Word 檔上「就地修改並保留全部原始格式」——
  改寫輸出的是新檔案，原檔的字型、表格、圖片不會帶過去。
- 4B 模型適合日常摘要、改寫、翻譯；長篇複雜草擬建議用完整版的 30B 模型。

### 速度預期（純 CPU）

- `qwen3-4b`：約每秒 10～25 個字。
- 第一次載入模型需要數十秒，之後會快很多。

---

## 常見問題

**Q：安裝到一半失敗？** 再執行一次 `install.bat`，會自動略過已完成的步驟。

**Q：「無法啟動 Ollama 服務」？** 重新開機後再執行一次 `install.bat`。

**Q：拖放工具說「連不上 Ollama」？** 先從開始選單開一次 Ollama。

**Q：下載到一半斷線？** 重新執行 `download.bat`，自動續傳。

**Q：如何完整移除？** 控制台解除安裝 Ollama、AnythingLLM、Tesseract、Python、pandoc，
再刪除 `C:\Users\<使用者>\.ollama` 資料夾。
