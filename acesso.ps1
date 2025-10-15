# Script de instalação e configuração do AnyDesk
# Configura acesso remoto com senha fixa

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INSTALADOR ANYDESK - ACESSO REMOTO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verifica se está executando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[!] Este script precisa ser executado como Administrador!" -ForegroundColor Red
    Write-Host "[*] Reiniciando como Administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "[*] Executando como Administrador..." -ForegroundColor Green
Write-Host ""

# Configurações
$anydeskUrl = "https://download.anydesk.com/AnyDesk.exe"
$anydeskPath = "$env:TEMP\AnyDesk.exe"
$installPath = "$env:ProgramFiles\AnyDesk"
$senha = "1a2b3c4d5e6f@"


try {
    # Baixa o AnyDesk
    Write-Host "[*] Baixando AnyDesk..." -ForegroundColor Yellow
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $anydeskUrl -OutFile $anydeskPath -UseBasicParsing
    Write-Host "[+] Download concluído!" -ForegroundColor Green
    Write-Host ""

    # Instala o AnyDesk
    Write-Host "[*] Instalando AnyDesk..." -ForegroundColor Yellow
    Start-Process -FilePath $anydeskPath -ArgumentList "--install `"$installPath`" --start-with-win --silent" -Wait
    Write-Host "[+] AnyDesk instalado!" -ForegroundColor Green
    Write-Host ""

    # Aguarda a instalação completar
    Start-Sleep -Seconds 5

    # Caminho do executável do AnyDesk instalado
    $anydeskExe = "$installPath\AnyDesk.exe"

    if (Test-Path $anydeskExe) {
        Write-Host "[*] Configurando acesso remoto desacompanhado..." -ForegroundColor Yellow

        # Define a senha para acesso desacompanhado
        $process = Start-Process -FilePath $anydeskExe -ArgumentList "--set-password" -PassThru -WindowStyle Hidden
        Start-Sleep -Seconds 2

        # Envia a senha via stdin (método alternativo usando COM)
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.SendKeys]::SendWait($senha)
        Start-Sleep -Milliseconds 500
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

        # Configura permissões de acesso desacompanhado
        & $anydeskExe --set-password=$senha 2>$null

        Write-Host "[+] Senha configurada!" -ForegroundColor Green
        Write-Host ""

        # Obtém o ID do AnyDesk
        Write-Host "[*] Obtendo ID do AnyDesk..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3

        $anydeskId = & $anydeskExe --get-id 2>$null

        if ($anydeskId) {
            Write-Host "[+] ID do AnyDesk: $anydeskId" -ForegroundColor Green -BackgroundColor Black

            $computerName = $env:COMPUTERNAME
            $userName = $env:USERNAME
            $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

            # Monta a mensagem para exibir e copiar
            $mensagem = @"
========================================
   INFORMAÇÕES DE ACESSO REMOTO
========================================

Computador: $computerName
Usuário: $userName
ID AnyDesk: $anydeskId
Senha: $senha
Data/Hora: $timestamp

========================================
"@

            # Exibe as informações na tela
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "   INFORMAÇÕES DE ACESSO REMOTO" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Computador: " -NoNewline -ForegroundColor Yellow
            Write-Host $computerName -ForegroundColor White
            Write-Host "Usuário: " -NoNewline -ForegroundColor Yellow
            Write-Host $userName -ForegroundColor White
            Write-Host "ID AnyDesk: " -NoNewline -ForegroundColor Yellow
            Write-Host $anydeskId -ForegroundColor Green
            Write-Host "Senha: " -NoNewline -ForegroundColor Yellow
            Write-Host $senha -ForegroundColor Green
            Write-Host "Data/Hora: " -NoNewline -ForegroundColor Yellow
            Write-Host $timestamp -ForegroundColor White
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""

            # Aguarda 10 segundos
            Write-Host "[*] Copiando informações para área de transferência em 10 segundos..." -ForegroundColor Yellow
            for ($i = 10; $i -gt 0; $i--) {
                Write-Host "    $i..." -ForegroundColor Cyan
                Start-Sleep -Seconds 1
            }

            # Copia para área de transferência usando clip.exe
            Write-Host ""
            $mensagem | clip.exe
            Write-Host "[+] ✓ Informações COPIADAS para área de transferência!" -ForegroundColor Green -BackgroundColor Black
            Write-Host "[+] ✓ Aperte Ctrl+V para colar!" -ForegroundColor Green
            Write-Host ""
        }

        # Configura para iniciar com o Windows
        Write-Host "[*] Configurando inicialização automática..." -ForegroundColor Yellow
        & $anydeskExe --install-service 2>$null

        Write-Host "[+] Serviço instalado e configurado!" -ForegroundColor Green
        Write-Host ""

    } else {
        Write-Host "[!] Erro: AnyDesk não encontrado após instalação!" -ForegroundColor Red
        exit 1
    }

    # Limpa arquivo temporário
    if (Test-Path $anydeskPath) {
        Remove-Item $anydeskPath -Force
    }

    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  INSTALAÇÃO CONCLUÍDA COM SUCESSO!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Informações de Acesso:" -ForegroundColor Cyan
    Write-Host "  ID AnyDesk: $anydeskId" -ForegroundColor White
    Write-Host "  Senha: $senha" -ForegroundColor White
    Write-Host ""
    Write-Host "[*] O AnyDesk está configurado para iniciar automaticamente." -ForegroundColor Yellow
    Write-Host ""

} catch {
    Write-Host "[!] Erro durante a instalação: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
