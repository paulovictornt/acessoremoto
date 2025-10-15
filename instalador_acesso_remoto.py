import os
import sys
import subprocess
import urllib.request
import tempfile

def baixar_e_executar_powershell(url_github):
    """
    Baixa o script PowerShell do GitHub e executa
    """
    try:
        print("[*] Iniciando instalador de acesso remoto...")

        # Converte URL do GitHub para raw se necessário
        if "github.com" in url_github and "/blob/" in url_github:
            url_download = url_github.replace("github.com", "raw.githubusercontent.com").replace("/blob/", "/")
        else:
            url_download = url_github

        print(f"[*] Baixando acesso.ps1 do GitHub...")

        # Cria arquivo temporário
        temp_dir = tempfile.gettempdir()
        ps1_path = os.path.join(temp_dir, "acesso.ps1")

        # Baixa o arquivo
        urllib.request.urlretrieve(url_download, ps1_path)
        print(f"[+] Script baixado em: {ps1_path}")

        # Executa o PowerShell
        print("[*] Executando script PowerShell...")
        comando = [
            "powershell.exe",
            "-ExecutionPolicy", "Bypass",
            "-NoProfile",
            "-File", ps1_path
        ]

        processo = subprocess.Popen(
            comando,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding='utf-8',
            errors='ignore'
        )

        # Mostra output em tempo real
        for linha in processo.stdout:
            print(linha.strip())

        processo.wait()

        if processo.returncode == 0:
            print("[+] Acesso remoto instalado com sucesso!")
        else:
            print(f"[!] Erro ao executar script. Código: {processo.returncode}")
            stderr = processo.stderr.read()
            if stderr:
                print(f"[!] Erro: {stderr}")

        # Limpa arquivo temporário
        try:
            os.remove(ps1_path)
        except:
            pass

    except Exception as e:
        print(f"[!] Erro: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    print("=" * 50)
    print("    INSTALADOR DE ACESSO REMOTO")
    print("=" * 50)
    print()

    # Coloque aqui o link do seu arquivo no GitHub
    # Exemplo: "https://raw.githubusercontent.com/usuario/repo/main/acesso.ps1"
    # Ou URL normal: "https://github.com/usuario/repo/blob/main/acesso.ps1"
    URL_GITHUB = "https://raw.githubusercontent.com/paulovictornt/acessoremoto/main/acesso.ps1"

    # Ou pegue da linha de comando
    if len(sys.argv) > 1:
        URL_GITHUB = sys.argv[1]

    if "SEU_LINK" in URL_GITHUB or URL_GITHUB == "SEU_LINK_GITHUB_AQUI":
        print("[!] ATENÇÃO: Configure a URL_GITHUB com o link do seu arquivo no GitHub!")
        print("[!] Ou execute: python instalador_acesso_remoto.py <URL_DO_GITHUB>")
        print("\nPasso a passo:")
        print("1. Crie um repositório público no GitHub")
        print("2. Faça upload do acesso.ps1")
        print("3. Copie o link do arquivo (pode ser normal ou raw)")
        sys.exit(1)

    baixar_e_executar_powershell(URL_GITHUB)
