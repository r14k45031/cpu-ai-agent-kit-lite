# ============================================================
#  純 CPU 地端 AI 文書 Agent（輕量版）— 離線一鍵安裝腳本
#  適用：Windows 10/11 64 位元，全新電腦，不需要網路、不需要 GPU
#  用法：雙擊 install.bat（或以 PowerShell 執行本檔）
# ============================================================
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

function Wait-OllamaServer {
    for ($i = 0; $i -lt 45; $i++) {
        try {
            Invoke-RestMethod 'http://127.0.0.1:11434/api/version' -TimeoutSec 3 | Out-Null
            return $true
        } catch { Start-Sleep -Seconds 2 }
    }
    return $false
}

Write-Host ''
Write-Host '=============================================='
Write-Host '  純 CPU 地端 AI 文書 Agent 安裝程式（輕量版）'
Write-Host '=============================================='
Write-Host ''

# ---- 環境檢查 ----------------------------------------------
$ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$freeGB = [math]::Round((Get-PSDrive C).Free / 1GB)
Write-Host ("偵測到記憶體 {0} GB，C 槽剩餘空間 {1} GB" -f $ramGB, $freeGB)
if ($freeGB -lt 15) {
    Write-Warning '建議 C 槽至少保留 15 GB 空間（模型匯入時會複製一份到系統）。'
}
if ($ramGB -lt 8) {
    Write-Warning '記憶體不足 8 GB：模型仍可執行但速度較慢，建議關閉其他程式。'
}
Write-Host ''

# ---- 步驟 1/7：安裝 Ollama 推論引擎 -------------------------
$ollama = Join-Path $env:LOCALAPPDATA 'Programs\Ollama\ollama.exe'
if (Test-Path $ollama) {
    Write-Host '[1/7] Ollama 已安裝，略過。'
} else {
    Write-Host '[1/7] 安裝 Ollama 推論引擎（約需 1-3 分鐘）...'
    Start-Process -Wait (Join-Path $root 'installers\OllamaSetup.exe') `
        -ArgumentList '/VERYSILENT', '/NORESTART', '/SUPPRESSMSGBOXES'
    if (-not (Test-Path $ollama)) { throw 'Ollama 安裝失敗，請手動執行 installers\OllamaSetup.exe' }
    Write-Host '      Ollama 安裝完成。'
}

# 啟動 Ollama 服務
try {
    Invoke-RestMethod 'http://127.0.0.1:11434/api/version' -TimeoutSec 3 | Out-Null
} catch {
    Start-Process $ollama -ArgumentList 'serve' -WindowStyle Hidden
}
if (-not (Wait-OllamaServer)) { throw '無法啟動 Ollama 服務，請重新開機後再執行本腳本一次。' }
Write-Host '      Ollama 服務已啟動 (http://127.0.0.1:11434)。'

# ---- 步驟 2/7：匯入本機模型 ---------------------------------
Write-Host '[2/7] 匯入 AI 模型（大檔案要複製與計算雜湊，約需 3-10 分鐘，請耐心等候）...'

$systemPrompt = '你是專業的中文文書處理助理，擅長摘要、潤稿、改寫、翻譯、草擬公文與商務文件。除非使用者另有要求，一律使用繁體中文（台灣用語）回覆。'

$models = @(
    @{ Name = 'qwen3-4b'; Gguf = 'Qwen3-4B-Instruct-2507-Q4_K_M.gguf'; Chat = $true },
    @{ Name = 'qwen3-vl'; Gguf = 'Qwen3-VL-4B-Instruct-Q4_K_M.gguf'
       Proj = 'Qwen3-VL-4B-mmproj-F16.gguf';                           Chat = $false },
    @{ Name = 'bge-m3';   Gguf = 'bge-m3-Q8_0.gguf';                   Chat = $false }
)

$installed = (& $ollama list) -join "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

foreach ($m in $models) {
    $ggufPath = Join-Path $root ('models\' + $m.Gguf)
    if (-not (Test-Path $ggufPath)) {
        Write-Warning ("找不到模型檔 models\{0}，跳過 {1}。" -f $m.Gguf, $m.Name)
        continue
    }
    if ($installed -match [regex]::Escape($m.Name + ':')) {
        Write-Host ("      {0} 已存在，略過。" -f $m.Name)
        continue
    }
    if ($m.Proj) {
        $projPath = Join-Path $root ('models\' + $m.Proj)
        if (-not (Test-Path $projPath)) {
            Write-Warning ("找不到視覺投影器 models\{0}，跳過 {1}。" -f $m.Proj, $m.Name)
            continue
        }
        $mfContent = @"
FROM $ggufPath
FROM $projPath
PARAMETER num_ctx 8192
PARAMETER temperature 0.7
SYSTEM 你是圖片理解助理，一律使用繁體中文（台灣用語）回覆。
"@
    } elseif ($m.Chat) {
        $mfContent = @"
FROM $ggufPath
PARAMETER num_ctx 8192
PARAMETER temperature 0.7
PARAMETER top_p 0.8
PARAMETER top_k 20
SYSTEM $systemPrompt
"@
    } else {
        $mfContent = "FROM $ggufPath"
    }
    $mfPath = Join-Path $env:TEMP ('Modelfile_' + $m.Name + '.txt')
    [System.IO.File]::WriteAllText($mfPath, $mfContent, $utf8NoBom)
    Write-Host ("      匯入 {0} ..." -f $m.Name)
    & $ollama create $m.Name -f $mfPath
    if ($LASTEXITCODE -ne 0) { throw ("模型 {0} 匯入失敗。" -f $m.Name) }
}

# ---- 步驟 3/7：安裝 AnythingLLM 圖形介面 --------------------
$allmInstalled = Get-ChildItem (Join-Path $env:LOCALAPPDATA 'Programs') -Filter '*anythingllm*' -ErrorAction SilentlyContinue
if ($allmInstalled) {
    Write-Host '[3/7] AnythingLLM 已安裝，略過。'
} else {
    Write-Host '[3/7] 安裝 AnythingLLM 圖形介面...'
    Start-Process -Wait (Join-Path $root 'installers\AnythingLLMDesktop.exe') -ArgumentList '/S'
    Write-Host '      AnythingLLM 安裝完成。'
}

# ---- 步驟 4/7：安裝 pandoc 文件轉檔工具（選用） --------------
Write-Host '[4/7] 安裝 pandoc 文件轉檔工具...'
try {
    Start-Process -Wait 'msiexec.exe' -ArgumentList '/i',
        ('"' + (Join-Path $root 'installers\pandoc-3.10-windows-x86_64.msi') + '"'),
        '/qn', '/norestart'
    Write-Host '      pandoc 安裝完成。'
} catch {
    Write-Warning 'pandoc 安裝失敗（不影響主要功能），可稍後手動執行 installers 內的 msi。'
}

# ---- 步驟 5/7：安裝 Tesseract OCR（掃描 PDF 文字辨識） -------
$tessExe = 'C:\Program Files\Tesseract-OCR\tesseract.exe'
try {
    if (Test-Path $tessExe) {
        Write-Host '[5/7] Tesseract OCR 已安裝，略過。'
    } else {
        Write-Host '[5/7] 安裝 Tesseract OCR（會跳出權限確認視窗，請按「是」）...'
        Start-Process -Wait (Join-Path $root 'installers\tesseract-ocr-w64-setup-5.4.0.20240606.exe') -ArgumentList '/S'
    }
    $tessData = 'C:\Program Files\Tesseract-OCR\tessdata\chi_tra.traineddata'
    $srcData = Join-Path $root 'tools\tessdata\chi_tra.traineddata'
    if ((Test-Path $tessExe) -and -not (Test-Path $tessData) -and (Test-Path $srcData)) {
        try {
            Copy-Item $srcData $tessData -Force -ErrorAction Stop
        } catch {
            Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile', '-Command',
                ("Copy-Item -LiteralPath '{0}' -Destination '{1}' -Force" -f $srcData, $tessData)
        }
        Write-Host '      已加入繁體中文辨識資料。'
    }
} catch {
    Write-Warning 'Tesseract 安裝失敗（只影響掃描 PDF 的 OCR，其他功能不受影響）。'
}

# ---- 步驟 6/7：安裝 Python 與文書自動化工具 ------------------
try {
    $py = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python313\python.exe'
    if (Test-Path $py) {
        Write-Host '[6/7] Python 已安裝，略過安裝程式。'
    } else {
        Write-Host '[6/7] 安裝 Python 3.13...'
        Start-Process -Wait (Join-Path $root 'installers\python-3.13.14-amd64.exe') `
            -ArgumentList '/quiet', 'InstallAllUsers=0', 'PrependPath=1', 'Include_test=0'
    }
    if (-not (Test-Path $py)) { throw 'Python 安裝程式未完成' }
    Write-Host '      安裝離線 Python 套件（python-docx / openpyxl / PyMuPDF）...'
    & $py -m pip install --no-index --find-links (Join-Path $root 'tools\wheels') `
        --quiet --disable-pip-version-check python-docx openpyxl pymupdf
    if ($LASTEXITCODE -ne 0) { throw 'pip 離線套件安裝失敗' }
    Write-Host '      文書自動化工具就緒（tools 資料夾內的 .bat）。'
} catch {
    Write-Warning ('Python 工具安裝失敗：' + $_.Exception.Message + '（不影響 AnythingLLM 主要功能）')
}

# ---- 步驟 7/7：驗證 -----------------------------------------
Write-Host '[7/7] 驗證已安裝的模型：'
& $ollama list
Write-Host ''
Write-Host '=============================================='
Write-Host '  安裝完成！接下來：'
Write-Host '  1. 從開始選單開啟 AnythingLLM'
Write-Host '  2. LLM 供應商選 Ollama，模型選 qwen3-4b'
Write-Host '  3. Embedder（嵌入模型）選 Ollama 的 bge-m3'
Write-Host '  4. 建立工作區，把文件拖進去就能開始問答'
Write-Host '  5. 批次摘要、OCR、AI 改寫、轉 Word：'
Write-Host '     把檔案拖到 tools 資料夾裡的 .bat 上即可'
Write-Host '  詳細說明請看 README.md'
Write-Host '=============================================='
