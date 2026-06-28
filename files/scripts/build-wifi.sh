#!/usr/bin/env bash
set -e

echo "Preparando ambiente para build do driver Wi-Fi (RPM)..."

# Instala ferramentas necessárias para criar o RPM
rpm-ostree install rpm-build rpmdevtools dkms

# Prepara a estrutura do rpmbuild
mkdir -p $HOME/rpmbuild/{SOURCES,SPECS,RPMS,SRPMS,BUILD,BUILDROOT}

# Baixa a spec file (use a branch 'bluetooth' como você identificou)
# Ajuste o link se necessário para a branch específica
curl -L -s https://raw.githubusercontent.com/shenmintao/aic8800d80/bluetooth/bazzite/aic8800d80.spec -o $HOME/rpmbuild/SPECS/aic8800d80.spec

# Baixa os arquivos necessários pela spec
spectool -g -R $HOME/rpmbuild/SPECS/aic8800d80.spec

# Compila o RPM
# O parâmetro --define "uname $(uname -r)" garante que o driver seja feito para o kernel atual
rpmbuild --define "uname $(uname -r)" -bb $HOME/rpmbuild/SPECS/aic8800d80.spec

# Instala o pacote gerado
# O comando abaixo encontra o arquivo .rpm gerado automaticamente
rpm-ostree install $HOME/rpmbuild/RPMS/x86_64/aic8800d80-*.rpm

echo "Driver Wi-Fi empacotado e instalado via RPM com sucesso."