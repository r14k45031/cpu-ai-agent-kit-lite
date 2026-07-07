# ============================================================
#  下載安裝包所需的全部大型檔案（在「有網路」的電腦上執行）
#  輕量版：只含 4B 模型，總下載量約 8.5 GB，8 GB 記憶體電腦可跑
#  下載完成後，把整個資料夾複製到隨身碟，
#  帶到離線電腦執行 install.bat 即可。
# ============================================================
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$curl = "$env:SystemRoot\System32\curl.exe"
if (-not (Test-Path $curl)) { throw '找不到 curl.exe（需要 Windows 10 1803 以上版本）' }

$files = @(
    @{ Out = 'installers\OllamaSetup.exe'
       Url = 'https://ollama.com/download/OllamaSetup.exe' },
    @{ Out = 'installers\AnythingLLMDesktop.exe'
       Url = 'https://cdn.anythingllm.com/latest/AnythingLLMDesktop.exe' },
    @{ Out = 'installers\pandoc-3.10-windows-x86_64.msi'
       Url = 'https://github.com/jgm/pandoc/releases/download/3.10/pandoc-3.10-windows-x86_64.msi' },
    @{ Out = 'installers\tesseract-ocr-w64-setup-5.4.0.20240606.exe'
       Url = 'https://github.com/UB-Mannheim/tesseract/releases/download/v5.4.0.20240606/tesseract-ocr-w64-setup-5.4.0.20240606.exe' },
    @{ Out = 'installers\python-3.13.14-amd64.exe'
       Url = 'https://www.python.org/ftp/python/3.13.14/python-3.13.14-amd64.exe' },
    @{ Out = 'tools\tessdata\chi_tra.traineddata'
       Url = 'https://github.com/tesseract-ocr/tessdata/raw/main/chi_tra.traineddata' },
    @{ Out = 'models\bge-m3-Q8_0.gguf'
       Url = 'https://huggingface.co/gpustack/bge-m3-GGUF/resolve/main/bge-m3-Q8_0.gguf' },
    @{ Out = 'models\Qwen3-4B-Instruct-2507-Q4_K_M.gguf'
       Url = 'https://huggingface.co/unsloth/Qwen3-4B-Instruct-2507-GGUF/resolve/main/Qwen3-4B-Instruct-2507-Q4_K_M.gguf' },
    @{ Out = 'models\Qwen3-VL-4B-Instruct-Q4_K_M.gguf'
       Url = 'https://huggingface.co/unsloth/Qwen3-VL-4B-Instruct-GGUF/resolve/main/Qwen3-VL-4B-Instruct-Q4_K_M.gguf' },
    @{ Out = 'models\Qwen3-VL-4B-mmproj-F16.gguf'
       Url = 'https://huggingface.co/unsloth/Qwen3-VL-4B-Instruct-GGUF/resolve/main/mmproj-F16.gguf' }
)

# Python 離線套件（版本鎖定，從 PyPI 官方取得）
$wheels = @(
    @{ Pkg = 'python-docx';       Ver = '1.2.0';  File = 'python_docx-1.2.0-py3-none-any.whl' },
    @{ Pkg = 'lxml';              Ver = '6.1.1';  File = 'lxml-6.1.1-cp313-cp313-win_amd64.whl' },
    @{ Pkg = 'typing-extensions'; Ver = '4.16.0'; File = 'typing_extensions-4.16.0-py3-none-any.whl' },
    @{ Pkg = 'openpyxl';          Ver = '3.1.5';  File = 'openpyxl-3.1.5-py2.py3-none-any.whl' },
    @{ Pkg = 'et-xmlfile';        Ver = '2.0.0';  File = 'et_xmlfile-2.0.0-py3-none-any.whl' },
    @{ Pkg = 'pymupdf';           Ver = '1.28.0'; File = 'pymupdf-1.28.0-cp310-abi3-win_amd64.whl' },
    @{ Pkg = 'python-pptx';       Ver = '1.0.2';  File = 'python_pptx-1.0.2-py3-none-any.whl' },
    @{ Pkg = 'pillow';            Ver = '12.3.0'; File = 'pillow-12.3.0-cp313-cp313-win_amd64.whl' },
    @{ Pkg = 'pymupdf4llm';       Ver = '1.28.0'; File = 'pymupdf4llm-1.28.0-py3-none-any.whl' }
)

foreach ($d in 'installers', 'models', 'tools\tessdata', 'tools\wheels') {
    New-Item -ItemType Directory -Force (Join-Path $root $d) | Out-Null
}

$freeGB = [math]::Round((Get-PSDrive ($root.Substring(0,1))).Free / 1GB)
Write-Host ("目前磁碟剩餘 {0} GB；輕量版全部下載約需 8.5 GB。" -f $freeGB)
Write-Host '中斷後重新執行本腳本會從斷點續傳。'
Write-Host ''

$i = 0
foreach ($f in $files) {
    $i++
    $out = Join-Path $root $f.Out
    Write-Host ("[{0}/{1}] {2}" -f $i, $files.Count, $f.Out)
    & $curl -L --fail --retry 8 --retry-delay 10 -C - -# -o $out $f.Url
    if ($LASTEXITCODE -ne 0) { throw ("下載失敗：{0}" -f $f.Url) }
}

Write-Host '下載 Python 離線套件...'
foreach ($w in $wheels) {
    $out = Join-Path $root ('tools\wheels\' + $w.File)
    if (Test-Path $out) { continue }
    $meta = Invoke-RestMethod ('https://pypi.org/pypi/{0}/{1}/json' -f $w.Pkg, $w.Ver)
    $url = ($meta.urls | Where-Object { $_.filename -eq $w.File }).url
    if (-not $url) { throw ("PyPI 上找不到 {0}" -f $w.File) }
    Write-Host ('  ' + $w.File)
    & $curl -L --fail --retry 8 --retry-delay 10 -s -o $out $url
    if ($LASTEXITCODE -ne 0) { throw ("下載失敗：{0}" -f $w.File) }
}

Write-Host ''
Write-Host '=============================================='
Write-Host '  全部下載完成！'
Write-Host '  下一步：把整個資料夾複製到隨身碟，'
Write-Host '  帶到目標電腦雙擊 install.bat 離線安裝。'
Write-Host '=============================================='
