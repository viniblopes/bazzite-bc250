#!/usr/bin/env bash
set -e

echo "Preparando ambiente para build do driver Wi-Fi (RPM)..."

# 1. Captura a versão real do kernel do Bazzite dentro da imagem
KVER=$(ls /usr/lib/modules | head -n 1)
echo "Construindo para o kernel do Bazzite: $KVER"

# Instala ferramentas necessárias para criar o RPM
rpm-ostree install rpm-build rpmdevtools

# Prepara a estrutura do rpmbuild
mkdir -p $HOME/rpmbuild/{SOURCES,SPECS,RPMS,SRPMS,BUILD,BUILDROOT}

# Baixa a spec file
curl -L -s https://raw.githubusercontent.com/shenmintao/aic8800d80/bluetooth/bazzite/aic8800d80.spec -o $HOME/rpmbuild/SPECS/aic8800d80.spec

# Baixa os arquivos necessários pela spec
spectool -g -R $HOME/rpmbuild/SPECS/aic8800d80.spec

# Compila o RPM
# 2. Substituímos $(uname -r) pela variável $KVER
rpmbuild --define "uname $KVER" -bb $HOME/rpmbuild/SPECS/aic8800d80.spec

# Instala o pacote gerado
rpm-ostree install $HOME/rpmbuild/RPMS/x86_64/aic8800d80-*.rpm

echo "Driver Wi-Fi empacotado e instalado via RPM com sucesso."